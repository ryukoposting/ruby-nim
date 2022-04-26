
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# 

import ../ruby/lowlevel

type
  RubyValue* = concept x
    ## Concept covering any Nim value that represents a Ruby RawValue.
    x.rawVal is RawValue

  RubyObject* {.rbmark.} = object
    rawVal*: RawValue

  RubyModule* {.rbmark.} = object
    rawVal*: RawValue

  RubyObjectType*[T] = object
    rbDataType*: RbDataType
    rawVal*: RawValue

  RubyClass* {.rbmark.} = object
    rawVal*: RawValue

  RubyArray* {.rbmark.} = object
    rawVal*: RawValue

  RubyHash* {.rbmark.} = object
    rawVal*: RawValue

  RubyRegexp* {.rbmark.} = object
    rawVal*: RawValue

func `rawVal`* (rv: RawValue): RawValue = rv
