#include "mutex.h"
#include "queues.h"
#include "xscope_host_shared.h"

mutex_t g_mutex;

socket_data_t g_socket_data[MAX_NUM_SOCKETS];
int g_socket_data_initialised = 0;

void initialize_socket_data()
{
  // Only let this function execute once
  if (!g_socket_data_initialised)
  {
    int i = 0;
    for (i = 0; i < MAX_NUM_SOCKETS; i++) {
      g_socket_data[i].sockfd = -1;
    }
    mutex_create(&g_mutex);
    g_socket_data_initialised = 1;
  }
}

void allocate_socket_data(int sockfd)
{
  int i;

  initialize_socket_data();

  for (i = 0; i < MAX_NUM_SOCKETS; i++) {
    if (g_socket_data[i].sockfd == -1) {
      g_socket_data[i].sockfd = sockfd;
      g_socket_data[i].upload_active = 0;
      return;
    }
  }
  // Not enough entries to handle this case
  assert(0);
}

socket_data_t *get_socket_data(int sockfd)
{
  int i;
  for (i = 0; i < MAX_NUM_SOCKETS; i++) {
    if (g_socket_data[i].sockfd == sockfd)
      return &g_socket_data[i];
  }
  // Failed to allocate the entry for this socket
  assert(0);
  return NULL;
}

upload_queue_entry_t *new_entry(unsigned int length, const unsigned char *data)
{
  int index = 0;
  upload_queue_entry_t *entry = malloc(sizeof(upload_queue_entry_t));
  entry->data = (unsigned char *)malloc(sizeof(char)+sizeof(int)+length);

  entry->data[index] = XTRACE_SOCKET_MSG_EVENT_TARGET_DATA;
  index += 1;
  *(unsigned int *)&(entry->data[index]) = length;
  index += 4;
  memcpy(&entry->data[index], data, length);
  index += length;
  entry->length = index;
  entry->next = NULL;
  return entry;
}

void free_entry(upload_queue_entry_t *entry)
{
  free(entry->data);
  free(entry);
}

static void manage_queue(socket_data_t *socket_data)
{
  int n = 0;
  upload_queue_entry_t *entry = socket_data->queue.head;

  // Can't start sending more data until outstanding data complete
  if (socket_data->upload_active)
    return;

  // No more data to send
  if (entry == NULL)
    return;

  // Send the head
  n = send(socket_data->sockfd, entry->data, entry->length, 0);
  if (n != entry->length)
    print_and_exit("ERROR: send failed on socket %d\n", socket_data->sockfd);

  socket_data->upload_active = 1;
}

void queue_add(int sockfd, upload_queue_entry_t *entry)
{
  socket_data_t *socket_data = get_socket_data(sockfd);

  mutex_acquire(&g_mutex);
  if (socket_data->queue.head == NULL) {
    socket_data->queue.head = entry;
    socket_data->queue.tail = entry;
  } else {
    socket_data->queue.tail->next = entry;
    socket_data->queue.tail = entry;
  }

  manage_queue(socket_data);
  mutex_release(&g_mutex);
}

void queue_complete_head(int sockfd)
{
  socket_data_t *socket_data = get_socket_data(sockfd);
  upload_queue_entry_t *entry = socket_data->queue.head;
  assert(entry != NULL);

  mutex_acquire(&g_mutex);
  socket_data->queue.head = entry->next;
  if (socket_data->queue.tail == entry)
    socket_data->queue.tail = NULL;

  free_entry(entry);
  socket_data->upload_active = 0;

  manage_queue(socket_data);
  mutex_release(&g_mutex);
}

