# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# 

import ../ruby/[lowlevel, types, misc, class]
import ../ruby/private/utils

type
  RubyRegexpFlag* = enum
    ReExtended = "EXTENDED",
    ReFixedEncoding = "FIXEDENCODING",
    ReIgnoreCase = "IGNORECASE",
    ReMultiLine = "MULTILINE",
    ReNoEncoding = "NOENCODING"


proc getRegexp*(rv: RawValue): RubyRegexp =
  requireType(rv, tRegexp, "RubyRegexp")
  RubyRegexp(rawVal: rv)

proc newRubyRegexp*(pattern: string, flags: varargs[RubyRegexpFlag]): RubyRegexp =
  let reClass = cRegexp.getClass()
  var flagval = 0
  for flag in flags:
    flagval = flagval or reClass.getConst($flag).getInt()

  return
    if flagval == 0:
      funcall(cRegexp, intern("new"), 1, pattern.toRawStr()).getRegexp()
    else:
      funcall(cRegexp, intern("new"), 2, pattern.toRawStr(), flagval.toRawInt()).getRegexp()
