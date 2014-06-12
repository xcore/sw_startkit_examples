#ifndef __queues_h__
#define __queues_h__

#define MAX_NUM_SOCKETS 10

#if defined(__XC__) || defined(__cplusplus)
extern "C" {
#endif

typedef struct upload_queue_entry_t {
  unsigned int length;
  unsigned char *data;
  struct upload_queue_entry_t *next;
} upload_queue_entry_t;

typedef struct upload_queue_t {
  upload_queue_entry_t *head;
  upload_queue_entry_t *tail;
} upload_queue_t;

typedef struct socket_data_t {
  int sockfd;
  int upload_active;
  upload_queue_t queue;
} socket_data_t;

void allocate_socket_data(int sockfd);
upload_queue_entry_t *new_entry(unsigned length, const unsigned char *data);
int queue_empty(int sockfd);
void queue_add(int sockfd, upload_queue_entry_t *entry);
void queue_complete_head(int sockfd);

#if defined(__XC__) || defined(__cplusplus)
}
#endif

#endif // __queues_h__
