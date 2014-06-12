// Copyright (c) 2013, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef __CONTROL_H__
#define __CONTROL_H__

#define GET_BIQUAD_ENABLED(x)    (x & 0x1)
#define SET_BIQUAD_ENABLED(x, v) ((x & ~0x1) | (v & 0x1))
#define GET_DRC_ENABLED(x)       (x & 0x2)
#define SET_DRC_ENABLED(x, v)    ((x & ~0x2) | ((v & 0x1) << 1))

#define PRE_GAIN_BITS   29
#define PRE_GAIN_OFFSET ((1 << PRE_GAIN_BITS) - 1)

typedef int dsp_state_t;

#include "startkit_gpio.h"
#include "drc.h"
#include "level.h"

#define LEVEL_ATTACK    1
#define LEVEL_RELEASE   2
#define LEVEL_THRESHOLD 4

/**
 * The control interface between the control and DSP processes.
 */
typedef interface control_if {
  /**
   * Set the pre-effects gain.
   *
   * \param gain          the gain value to set. Must be in the range 0-MAX_GAIN
   *                      (see app_conf.h).
   */
  void set_pre_gain(int gain);

  /**
   * Set the post-effects gain.
   *
   * \param gain          the gain value to set. Must be in the range 0-MAX_GAIN
   *                      (see app_conf.h).
   */
  void set_gain(int gain);

  /**
   * Control which effects are on (e.g. biquads/DRC)
   *
   * \param state   a bitfield indicating which effects are active.
   *
   */
  void set_effect(dsp_state_t state);

  /**
   * Configure the biquad decibel level for a given biquad index.
   *
   * \param chan_index    the channel number to modify. If chan_index == NUM_APP_CHANS
   *                      (see app_conf.h) then this will be applied to all channels.
   *
   * \param index         the biquad bank to modify.
   *
   * \param dbs           the new decibel level to set. Must be in the range 0-DBS
   *                      (see coeffs.h).
   */
  void set_dbs(int chan_index, int index, int dbs);

  /**
   * Get the current level for a biquad bank.
   *
   * \param chan_index    the channel number to modify. Must be in the range
   *                      0-NUM_APP_CHANS (see app_conf.h).
   *
   * \param index         the biquad bank to modify.
   *
   * \return   the current decibel level as an index in the range 0-DBS (see coeffs.h)
   */
  int  get_dbs(int chan_index, int index);

  /**
   * Configure the specified DRC entry
   *
   * \param index         the index into the DRC configuration table. Must be
   *                      in the range 0-DRC_NUM_THRESHOLDS (see drc.h).
   *
   * \param control       the DRC configuration structure.
   */
  void set_drc_entry(int index, drcControl &control);

  /**
   * Get the current configuration for the specified DRC entry
   *
   * \param index         the index into the DRC configuration table. Must be
   *                      in the range 0-DRC_NUM_THRESHOLDS (see drc.h).
   *
   * \return  the DRC configuration structure
   */
  drcControl get_drc_entry(int index);

  /**
   * Configure a subset of the level state for the specifiec channel
   *
   * \param chan_index    the channel number to modify. Must be in the range
   *                      0-NUM_APP_CHANS (see app_conf.h).
   *
   * \param state         the level state to apply.
   *
   * \param flags         a bitfield which indicates which bits of state are valid.
   */
  void set_level_entry(int chan_index, levelState &state, int flags);

  /**
   * Get the current level for the specifiec channel
   *
   * \param chan_index    the channel number to modify. Must be in the range
   *                      0-NUM_APP_CHANS (see app_conf.h).
   *
   * \return  the level state
   */
  levelState get_level_entry(int chan_index);

} control_if;

/**
 * A control task that listens to data being received over xscope,
 * interprets the commands and controls the DSP process.
 */
void control(chanend c_host_data,
    client startkit_led_if i_led,
    client startkit_button_if i_button,
    client control_if i_control);

#endif // __CONTROL_H__
