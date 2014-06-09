#include "mutex.h"
#include "xscope_host_shared.h"

// A mutex to ensure that the thread interactions are safe
#ifdef _WIN32

#include <windows.h> 
HANDLE g_mutex;
  
void mutex_create(mutex_t *mutex)
{
  *mutex = CreateMutex( 
      NULL,              // default security attributes
      FALSE,             // initially not owned
      NULL);             // unnamed mutex

  if (*mutex == NULL) 
    print_and_exit("ERROR: mutex init failed\n");
}

void mutex_destroy(mutex_t *mutex)
{
  CloseHandle(*mutex);
}

void mutex_acquire(mutex_t *mutex)
{
  DWORD result = WaitForSingleObject(*mutex, INFINITE);
  if (result != WAIT_OBJECT_0)
    print_and_exit("ERROR: mutex acquire failed\n");
}

void mutex_release(mutex_t *mutex)
{
  if (! ReleaseMutex(*mutex))
    print_and_exit("ERROR: mutex release failed\n");
}

#else

#include <pthread.h>
pthread_mutex_t g_mutex;

void mutex_create(mutex_t *mutex)
{
  if (pthread_mutex_init(mutex, NULL) != 0)
    print_and_exit("ERROR: mutex init failed\n");
}

void mutex_destroy(mutex_t *mutex)
{
  pthread_mutex_destroy(mutex);
}

void mutex_acquire(mutex_t *mutex)
{
  if (pthread_mutex_lock(mutex))
    print_and_exit("ERROR: mutex acquire failed\n");
}

void mutex_release(mutex_t *mutex)
{
  if (pthread_mutex_unlock(mutex))
    print_and_exit("ERROR: mutex release failed\n");
}

#endif
