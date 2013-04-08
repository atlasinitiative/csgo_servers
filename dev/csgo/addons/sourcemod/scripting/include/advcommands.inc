// File:   adgvanced.inc
// Author: X@IDER

#if defined _advanced_included_
  #endinput
#endif
#define _advanced_included_

/**
 * Format notify string
 *
 * @param admin			Admin, who performs action
 * @param target		Target of action
 * @param trans			Translation identity
 * @param ...			Arguments
 * @noreturn
 */
native Notify(admin,target,String:trans[],any:...);

/**
 * Format notify string
 *
 * @param admin			Admin, who performs action
 * @param target		Target of action
 * @param trans			Translation identity
 * @param ...			Arguments
 * @noreturn
 */
native Notify2(admin,String:target[],String:trans[],any:...);
