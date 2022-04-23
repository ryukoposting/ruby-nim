
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

  RubyObject* = object
    rawVal*: RawValue

  RubyModule* = object
    rawVal*: RawValue

  RubyObjectType*[T] = object
    rbDataType*: RbDataType
    rawVal*: RawValue

  RubyClass* = object
    rawVal*: RawValue

  RubyArray* = object
    rawVal*: RawValue

  RubyHash* = object
    rawVal*: RawValue

func `rawVal`* (rv: RawValue): RawValue = rv
