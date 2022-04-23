
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# 

import ../ruby/[misc, lowlevel, types, arrays]
import ../ruby/private/utils

proc getHash*(raw: RubyValue): RubyHash =
  requireType(raw.rawVal, tHash, "RubyHash")
  result.rawVal = raw

proc `[]`*(self: RubyHash, key: RubyValue): RawValue =
  self.rawVal.hashARef(key.rawVal)

proc `[]=`*(self: RubyHash, key, value: RubyValue) =
  self.rawVal.hashASet(key.rawVal, value.rawVal)

proc keys*(self: RubyHash): RubyArray =
  funcall(self.rawVal, intern("keys"), 0).getArray()

proc delete*(self: RubyHash, key: RubyValue): RawValue =
  funcall(self.rawVal, intern("delete"), 1, key.rawVal)
