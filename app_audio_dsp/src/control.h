#ifndef __control_h__
#define __control_h__

#define MAX_GAIN 0x7fffffff

typedef interface control_if {
  void set_dbs(int index, int dbs);

  void set_gain(int gain);

  void print();
} control_if;

void control(chanend c_host_data, client control_if i_control);

#endif // __control_h__
