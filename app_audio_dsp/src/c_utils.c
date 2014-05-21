#include <xs1.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <xccompat.h>

#include "c_utils.h"
#include "debug_print.h"

char get_next_char(const unsigned char **buffer)
{
  const unsigned char *ptr = *buffer;
  while (*ptr && isspace(*ptr))
    ptr++;

  *buffer = ptr + 1;
  return *ptr;
}

int convert_atoi_substr(const unsigned char **buffer)
{
  const unsigned char *ptr = *buffer;
  unsigned int value = 0;
  while (*ptr && isspace(*ptr))
    ptr++;

  if (*ptr == '\0')
    return 0;

  value = atoi((char*)ptr);
  debug_printf("value = '%d'\n", value);

  while (*ptr && !isspace(*ptr))
    ptr++;

  *buffer = ptr;
  return value;
}

