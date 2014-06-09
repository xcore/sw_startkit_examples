#ifndef __mutex_h__
#define __mutex_h__

#ifdef _WIN32
  #include <windows.h> 
  typedef HANDLE mutex_t;
#else
  #include <pthread.h>
  typedef pthread_mutex_t mutex_t;
#endif

void mutex_create(mutex_t *mutex);
void mutex_destroy(mutex_t *mutex);
void mutex_acquire(mutex_t *mutex);
void mutex_release(mutex_t *mutex);

#endif // __mutex_h__
