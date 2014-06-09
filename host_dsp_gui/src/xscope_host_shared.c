#include "xscope_host_shared.h"
#include "queues.h"

/*
 * Debug: Setting DEBUG to 1 will enable logging to 'run.log'.
 *        All data received on the socket will be logged.
 */
#define DEBUG 0
FILE *g_log = NULL;

/*
 * The number of attempts to connect to the socket before giving up
 */
#define MAX_NUM_CONNECT_RETRIES 20

/*
 * HOOKS: The application needs to implement the following hooks
 */

// Called with the registartions so that the app can map name->probe
void hook_registration_received(int sockfd, int xscope_probe, char *name);

// Called whenever data is received from the target
void hook_data_received(int sockfd, int xscope_probe, void *data, int data_len);

// Called whenever the application is existing
void hook_exiting();

#ifdef XSCOPE_HOST_HAS_PROMPT
  // The application needs to define the prompt if it is going to use
  // a console application. If it is NULL then it is assumed there is
  // no console on the host.
  extern const char *g_prompt;
#else
  const char *g_prompt = NULL;
#endif

/*
 * Library code
 */
int initialise_socket(char *ip_addr_str, char *port_str)
{
  int sockfd = 0;
  int n = 0;
  unsigned char command_buffer[1];
  struct sockaddr_in serv_addr;
  char *end_pointer = NULL;
  int port = 0;
  int connect_retries = 0;

  if (DEBUG)
    g_log = fopen("run.log", "w");

  signal(SIGINT, interrupt_handler);

#ifdef _WIN32
  {
    //Start up Winsock
    WSADATA wsadata;
    int retval = WSAStartup(0x0202, &wsadata);
    if (retval)
      print_and_exit("ERROR: WSAStartup failed with '%d'\n", retval);

    //Did we get the right Winsock version?
    if (wsadata.wVersion != 0x0202) {
      WSACleanup();
      print_and_exit("ERROR: WSAStartup version incorrect '%x'\n", wsadata.wVersion);
    }
  }
#endif // _WIN32

  // Need the fflush because there is no newline in the print
  printf("Connecting"); fflush(stdout);
  while (1) {
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) < 0)
      print_and_exit("ERROR: Could not create socket\n");

    memset(&serv_addr, 0, sizeof(serv_addr));

    // Parse the port parameter
    end_pointer = (char*)port_str;
    port = strtol(port_str, &end_pointer, 10);
    if (end_pointer == port_str)
      print_and_exit("ERROR: Failed to parse port\n");

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);

    if (inet_pton(AF_INET, ip_addr_str, &serv_addr.sin_addr) <= 0)
      print_and_exit("ERROR: inet_pton error occured\n");

    if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
      close(sockfd);

      if (connect_retries < MAX_NUM_CONNECT_RETRIES) {
        // Need the fflush because there is no newline in the print
        printf("."); fflush(stdout);
#ifdef _WIN32
        Sleep(1000);
#else
        sleep(1);
#endif
        connect_retries++;
      } else {
        print_and_exit("\nERROR: Connect failed on ip: %s, port: %s\n",ip_addr_str, port_str);
      }
    } else {
      break;
    }
  }

  // Send the command to request which event types to receive
  command_buffer[0] = XTRACE_SOCKET_MSG_EVENT_RECORD |
                      XTRACE_SOCKET_MSG_EVENT_PRINT  |
                      XTRACE_SOCKET_MSG_EVENT_REGISTER;
  n = send(sockfd, command_buffer, 1, 0);
  if (n != 1)
    print_and_exit("\nERROR: Command send failed\n");

  printf(" - connected to ip: %s, port: %s\n",ip_addr_str, port_str);

  allocate_socket_data(sockfd);
  return sockfd;
}

void interrupt_handler(int sig)
{
  hook_exiting();

  if (DEBUG) {
    fflush(g_log);
    fclose(g_log);
  }

  printf("\nFinishing\n");
  exit(1);
}

void print_and_exit(const char* format, ...)
{
  va_list argptr;
  va_start(argptr, format);
  vfprintf(stderr, format, argptr);
  va_end(argptr);
  exit(1);
}

int xscope_ep_request_upload(int sockfd, unsigned int length, const unsigned char *data)
{
  upload_queue_entry_t *entry = new_entry(length, data);
  queue_add(sockfd, entry);
  return XSCOPE_EP_SUCCESS;
}

#define EXTRACT_LEN_PLUS_STR(v)                    \
  if ((len + 4) > n)                               \
    break;                                         \
  int v##_strlen = EXTRACT_UINT(recv_buffer, len); \
  char *v = (char *)&recv_buffer[len + 4];         \
  len += 4 + v##_strlen;                           \
  if (len > n)                                     \
    break;                                         \

/*
 * Function to handle all data being received on the socket. It handles the
 * fact that full messages may not be received together and therefore needs
 * to keep the remainder of any message that hasn't been processed yet.
 */
void handle_sockets(int *sockfds, int no_of_sock)
{
  int num_remaining_bytes[MAX_NUM_SOCKETS];
  unsigned char recv_buffers[MAX_NUM_SOCKETS][MAX_RECV_BYTES];
  int i = 0;
  
  // Keep track of whether a message should be printed at the start of the line
  // and when the prompt needs to be printed
  int new_line = 1;
  
  //set of socket descriptors
  fd_set readfds;

  assert(no_of_sock < MAX_NUM_SOCKETS);
  for (i = 0; i < MAX_NUM_SOCKETS; i++) {
    num_remaining_bytes[i] = 0;
  }
   
  while(1)
  { 
    int max_sockfd = 0;
    int activity = 0;
    int sock_i = 0;

    // clear the socket set
    FD_ZERO(&readfds);
    // add sockets to set
    for (i = 0; i < no_of_sock; i++) {
      // if valid socket descriptor then add to read list
      if (sockfds[i] >= 0)
        FD_SET(sockfds[i], &readfds);
      
      // highest file descriptor number, need it for the select function
      if (sockfds[i] > max_sockfd)
        max_sockfd = sockfds[i];
    }

    // wait for an activity on one of the sockets, timeout is NULL, so wait indefinitely
    activity = select(max_sockfd + 1, &readfds, NULL, NULL, NULL);

#ifdef _WIN32
    if ((activity < 0) && (WSAGetLastError() != WSAEINTR)) {
#else
    if ((activity < 0) && (errno != EINTR)) {
#endif
      printf("select error\n");
      fflush(stdout);
    }
      
    // If something happened on the socket
    for (sock_i = 0; sock_i < no_of_sock; sock_i++) {
      unsigned char *recv_buffer = recv_buffers[sock_i];
      int *socket_remaining = &num_remaining_bytes[sock_i];
      int sockfd = sockfds[sock_i];

      if (FD_ISSET(sockfd, &readfds)) {
        int n;
        // read the incoming message
#ifdef _WIN32
        if ((n = recv(sockfd, &recv_buffer[*socket_remaining], MAX_RECV_BYTES - *socket_remaining, MSG_PARTIAL)) > 0) {
#else               
        if ((n = read(sockfd, &recv_buffer[*socket_remaining], MAX_RECV_BYTES - *socket_remaining)) > 0) {
#endif          
            
          if (DEBUG)
            fprintf(g_log, ">> Received %d", n);
            
          n += *socket_remaining;
          *socket_remaining = 0;
          if (DEBUG) {
            for (i = 0; i < n; i++) {
              if ((i % 16) == 0)
                fprintf(g_log, "\n");
              fprintf(g_log, "%02x ", recv_buffer[i]);
            }
            fprintf(g_log, "\n");
          }
            
          for (i = 0; i < n; ) {
            // Indicate when a block of data has been handled by the fact that the pointer can move on
            int increment = 0;

            switch (recv_buffer[i]) {

            case XTRACE_SOCKET_MSG_EVENT_PRINT: {
              // Data to print to the screen has been received
              unsigned int string_len = 0;

              // Need one byte for type, then 8 bytes of time stamp and 4 bytes of length
              if ((i + PRINT_EVENT_BYTES) <= n) {
                unsigned int string_len = EXTRACT_UINT(recv_buffer, i + 9);

                int string_start = i + PRINT_EVENT_BYTES;
                int string_end = i + PRINT_EVENT_BYTES + string_len;

                // Ensure the buffer won't overflow (has to be after variable
                // declaration for Windows c89 compile)
                assert(string_len < MAX_RECV_BYTES);

                if (string_end <= n) {
                  // Ensure the string is null-terminated - but remember the data byte
                  // in order to be able to restore it.
                  unsigned char tmp = recv_buffer[string_end];
                  recv_buffer[string_end] = '\0';

                  if (new_line && (g_prompt != NULL)) {
                    // When starting to print a message, emit a carriage return in order
                    // to overwrite the prompt
                    printf("\r");
                    new_line = 0;
                  }

                  fwrite(&recv_buffer[string_start], sizeof(unsigned char), string_len, stdout);

                  if (recv_buffer[string_end - 1] == '\n') {
                    // When a string ends with a newline then print the prompt again
                    if (g_prompt != NULL)
                      printf("%s", g_prompt);

                    new_line = 1;
                  }

                  // Because there is no newline character at the end of the prompt and there
                  // may be none at the end of the string then we need to flush explicitly
                  fflush(stdout);

                  // Restore the end character
                  recv_buffer[string_end] = tmp;

                  increment = PRINT_EVENT_BYTES + string_len;
                }  //(string_end <= n)
              }    //((i + PRINT_EVENT_BYTES) <= n)
              break;
            }

            case XTRACE_SOCKET_MSG_EVENT_RECORD:
              // Data has been received, put it into the pcap file
              if ((i + DATA_EVENT_HEADER_BYTES) <= n) {
                int xscope_probe = recv_buffer[i+1];
                int packet_len = EXTRACT_UINT(recv_buffer, i + 4);

                // Fixed-length data packets are encoded with a length of 0
                // but actually carry 8 bytes of data
                if (packet_len == 0)
                  packet_len = 8;

                if ((i + packet_len + DATA_EVENT_BYTES) <= n) {
                  // Data starts after the message header
                  int data_start = i + DATA_EVENT_HEADER_BYTES;

                  hook_data_received(sockfd, xscope_probe, &recv_buffer[data_start], packet_len);
                  increment = packet_len + DATA_EVENT_BYTES;
                }
              }
              break;

            case XTRACE_SOCKET_MSG_EVENT_TARGET_DATA:
                // The target acknowledges that it has received the message sent
                if ((i + TARGET_DATA_EVENT_BYTES) <= n) {
                  queue_complete_head(sockfd);
                  increment = TARGET_DATA_EVENT_BYTES;
                }
                break;

            case XTRACE_SOCKET_MSG_EVENT_REGISTER: {
              int id = EXTRACT_UINT(recv_buffer, i + 1);
              // Point to start of name_strlen
              int len = i + REGISTER_EVENT_HEADER_BYTES - 4;
              EXTRACT_LEN_PLUS_STR(name);
              EXTRACT_LEN_PLUS_STR(ps);

              if ((len + 4) > n)
                break; // Not enough data for user_type
              int user_type = EXTRACT_UINT(recv_buffer, len);
              len += 4;

              EXTRACT_LEN_PLUS_STR(user_name);

              hook_registration_received(sockfd, id, name);

              increment = len;
              break;
            }

            default:
                print_and_exit("ERROR: Message format corrupted (received %u)\n", recv_buffer[i]);

            } // switch

            if (increment) {
              i += increment;

            } else {
                // Only part of the packet received - store rest for next iteration
                *socket_remaining = n - i;
                memmove(recv_buffer, &recv_buffer[i], *socket_remaining);

                if (DEBUG)
                  fprintf(g_log, "%d remaining\n", *socket_remaining);

                break;
            }
          } 
        }
      }
    }  
  } //while(1)
}

