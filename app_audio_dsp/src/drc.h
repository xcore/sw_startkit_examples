#ifndef __drc_h__
#define __drc_h__

/* Apply gain, 0 to 0x7fffffff */
extern int do_gain(int sample, int gain);

/**
 * This function must be called prior to using the drc function.
 */
extern void initDrc();

/**
 * This function applies the DRC filter.
 *
 * \param xn value to be filtered in fixed point format. Results that do
 *               not fit are clipped to the maximum positive and negative
 *               values. Input values should nominally be in the range
 *               [-1..+1] leaving headroom for intermediate results.
 *
 * \return       Filtered value in fixed point format. 
 */
extern int drc(int xc);

#endif // __drc_h__
