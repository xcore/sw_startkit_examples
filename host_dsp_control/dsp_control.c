/*
 * Note that the device and listener should be run with the same port and IP.
 * For example:
 *
 *  xrun --xscope-realtime --xscope-port 127.0.0.1:12346 ...
 *
 *  ./packet_analyser -s 127.0.0.1 -p 12346
 *
 */
/*
 * Includes for thread support
 */
#ifdef _WIN32
#include <winsock.h>

int file_exists(char *filename)
{
  WIN32_FIND_DATA FindFileData;
  HANDLE handle = FindFirstFile(filename, &FindFileData);
  if (handle != INVALID_HANDLE_VALUE) {
    FindClose(handle);
    return 1;
  } else {
    return 0;
  }
}

#else

#include <pthread.h>
#include <unistd.h>

int file_exists(char *filename)
{
  if (access(filename, F_OK) != -1)
    return 1;
  else
    return 0;
}
#endif


#include "xscope_host_shared.h"

#define MAX_FILENAME_LEN 1024

const char *g_prompt = "";

/* Interface on which the glitch occurred */
int g_interface = 0;
/* Size of the data received */
int g_expected_words = 0;

/* The ID of the glitch probe determined from the registrations */
int g_glitch_probe = -1;

/* File is chosen on header reception */
FILE *g_file_handle = NULL;

void hook_registration_received(int sockfd, int xscope_probe, char *name)
{
  // Do nothing
}

void hook_data_received(int sockfd, int xscope_probe, void *data, int data_len)
{
  // Do nothing
}

void hook_exiting()
{
  // Do nothing
}

static char get_next_char(const char **buffer)
{
  const char *ptr = *buffer;
  int len = 0;
  while (*ptr && isspace(*ptr))
    ptr++;

  *buffer = ptr + 1;
  return *ptr;
}

static int convert_atoi_substr(const char **buffer)
{
  const char *ptr = *buffer;
  unsigned int value = 0;
  while (*ptr && isspace(*ptr))
    ptr++;

  if (*ptr == '\0')
    return 0;

  value = atoi((char*)ptr);

  while (*ptr && !isspace(*ptr))
    ptr++;

  *buffer = ptr;
  return value;
}

void print_console_usage()
{
  printf("Supported commands:\n");
  printf("  h|?     : print this help message\n");
  printf("  b B DB  : Configure bank B to DB\n");
  printf("            B - 0-N selects bank, a selects all\n");
  printf("  g G     : Set the gain to G (value 0-100)\n");
  printf("  q       : quit\n");
}

#define LINE_LENGTH 1024

static int validate_gain(char *buffer)
{
  const char *ptr = &buffer[1]; // Skip command
  const unsigned gain = convert_atoi_substr(&ptr);

  if ((ptr == &buffer[1]) || (gain > 100)) {
    printf("Invalid gain: specify a value between 0 and 100\n");
    return 0;
  }

  return 1;
}

/*
 * A separate thread to handle user commands to control the target.
 */
#ifdef _WIN32
DWORD WINAPI console_thread(void *arg)
#else
void *console_thread(void *arg)
#endif
{
  int sockfd = *(int *)arg;
  char buffer[LINE_LENGTH + 1];
  do {
    int i = 0;
    int c = 0;
    const char *ptr = NULL;
    char cmd = 0;

    for (i = 0; (i < LINE_LENGTH) && ((c = getchar()) != EOF) && (c != '\n'); i++)
      buffer[i] = tolower(c);
    buffer[i] = '\0';

    ptr = &buffer[0];
    cmd = get_next_char(&ptr);
    switch (cmd) {
      case 'q':
        print_and_exit("Done\n");
        break;

      case 'b':
        xscope_ep_request_upload(sockfd, i + 1, (const unsigned char *)buffer);
        break;

      case 'g':
        if (validate_gain(buffer))
          xscope_ep_request_upload(sockfd, i + 1, (const unsigned char *)buffer);
        break;

      case 'h':
      case '?':
        print_console_usage();
        break;

      default:
        xscope_ep_request_upload(sockfd, 1, (unsigned char *)&buffer);
        break;
    }
  } while (1);

#ifdef _WIN32
  return 0;
#else
  return NULL;
#endif
}

void usage(char *argv[])
{
  printf("Usage: %s [-s server_ip] [-p port]\n", argv[0]);
  printf("  -s server_ip :   The IP address of the xscope server (default %s)\n", DEFAULT_SERVER_IP);
  printf("  -p port      :   The port of the xscope server (default %s)\n", DEFAULT_PORT);
  exit(1);
}

int main(int argc, char *argv[])
{
#ifdef _WIN32
  HANDLE thread;
#else
  pthread_t tid;
#endif
  char *server_ip = DEFAULT_SERVER_IP;
  char *port_str = DEFAULT_PORT;
  int err = 0;
  int sockfds[1] = {0};
  int c = 0;

  // Ensure that stdout is not buffered for the auto-test framework
  setvbuf(stdout, NULL, _IOLBF, 0);

  while ((c = getopt(argc, argv, "s:p:")) != -1) {
    switch (c) {
      case 's':
        server_ip = optarg;
        break;
      case 'p':
        port_str = optarg;
        break;
      case ':': /* -f or -o without operand */
        fprintf(stderr, "Option -%c requires an operand\n", optopt);
        err++;
        break;
      case '?':
        fprintf(stderr, "Unrecognized option: '-%c'\n", optopt);
        err++;
    }
  }
  if (optind < argc)
    err++;

  if (err)
    usage(argv);

  sockfds[0] = initialise_socket(server_ip, port_str);

  // Now start the console
#ifdef _WIN32
  thread = CreateThread(NULL, 0, console_thread, &sockfds[0], 0, NULL);
  if (thread == NULL)
    print_and_exit("ERROR: Failed to create console thread\n");
#else
  err = pthread_create(&tid, NULL, &console_thread, &sockfds[0]);
  if (err != 0)
    print_and_exit("ERROR: Failed to create console thread\n");
#endif

  handle_sockets(sockfds, 1);
  return 0;
}

