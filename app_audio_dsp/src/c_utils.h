#ifndef __C_UTILS_H__
#define __C_UTILS_H__

#include <xccompat.h>

#ifdef __XC__
extern "C" {
#endif

char get_next_char(const unsigned char **buffer);
int convert_atoi_substr(const unsigned char **buffer);

#ifdef __XC__
}
#endif

#endif // __C_UTILS_H__
