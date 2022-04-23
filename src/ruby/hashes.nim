
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# 

import ../ruby/[lowlevel, types, arrays, calls]
import ../ruby/private/utils

proc getHash*(raw: RubyValue): RubyHash =
  ## Get a RubyHash object from any RubyValue. This function
  ## will throw an exception if `raw` isn't a ruby Hash!
  requireType(raw.rawVal, tHash, "RubyHash")
  result.rawVal = raw

proc newRubyHash*(defaultValue: RubyValue = qNil): RubyHash =
  ## Create a new, empty ruby Hash object.
  ## This function works the same as Ruby's `Hash.new`.
  cHash.call("new", defaultValue).getHash()

proc `[]`*(self: RubyHash, key: RubyValue): RawValue =
  ## Access a ruby Hash.
  self.rawVal.hashARef(key.rawVal)

proc `[]=`*(self: RubyHash, key, value: RubyValue) =
  ## Put a value into a ruby Hash.
  self.rawVal.hashASet(key.rawVal, value.rawVal)

proc keys*(self: RubyHash): RubyArray =
  ## Get a RubyArray containing all of the keys in the
  ## ruby Hash. This works the same as ruby's `Hash.keys`
  ## method.
  funcall(self.rawVal, intern("keys"), 0).getArray()

proc delete*(self: RubyHash, key: RubyValue): RawValue =
  ## Delete a key in the ruby Hash. This works the same
  ## as ruby's `Hash.delete` method.
  funcall(self.rawVal, intern("delete"), 1, key.rawVal)
