
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# 

import ../ruby/[lowlevel, types, misc, calls]
import ../ruby/private/utils

proc getArray*(raw: RubyValue): RubyArray =
  ## Get a RubyArray from any RubyValue. This function will throw
  ## an exception if `raw` isn't a ruby Array!
  requireType(raw.rawVal, tArray, "RubyArray")
  result.rawVal = raw

proc newRubyArray*(initialSize = 0): RubyArray =
  ## Create a new ruby Array object. This function works
  ## the same as Ruby's `Array.new`.
  cArray.call("new", initialSize.toRawInt()).getArray()

proc `[]`*(self: RubyArray, index: int): RawValue =
  ## Access a ruby Array.
  self.rawVal.aryEntry(index)

proc len*(self: RubyArray): int =
  ## Get the length of the ruby Array.
  self.rawVal.aryLength()

proc toSeq*(self: RubyArray): seq[RawValue] =
  ## Convert the ruby Array to a `seq` of RawValues.
  result = @[]
  for i in 0..<self.len():
    result.add self[i]

proc map*(self: RubyArray, bloc: RubyValue): RubyArray =
  ## Equivalent to Ruby's `Array.map`
  var id = intern("map")
  result.rawVal = self.rawVal.funcallWithBlock(id, 0, nil, bloc.rawVal)

proc select*(self: RubyArray, bloc: RubyValue): RubyArray =
  ## Equivalent to Ruby's `Array.select`
  var id = intern("select")
  result.rawVal = self.rawVal.funcallWithBlock(id, 0, nil, bloc.rawVal)

proc sort*(self: RubyArray, bloc: RubyValue): RubyArray =
  ## Equivalent to Ruby's `Array.sort`
  var id = intern("sort")
  result.rawVal = self.rawVal.funcallWithBlock(id, 0, nil, bloc.rawVal)

proc sort*(self: RubyArray): RawValue =
  ## Equivalent to Ruby's `Array.sort`
  var id = intern("sort")
  result = self.rawVal.funcall(id, 0)

proc shift*(self: RubyArray): RawValue =
  ## Equivalent to Ruby's `Array.shift`
  var id = intern("shift")
  result = self.rawVal.funcall(id, 0)

proc push*(self: RubyArray, value: RubyValue): RawValue =
  ## Equivalent to Ruby's `Array.push`
  var id = intern("push")
  result = self.rawVal.funcall(id, 1, value.rawVal)

proc sum*(self: RubyArray): RawValue =
  ## Equivalent to Ruby's `Array.sum`
  var id = intern("sum")
  result = self.rawVal.funcall(id, 0)

proc take*(self: RubyArray, n: int): RubyArray =
  ## Equivalent to Ruby's `Array.take`
  var id = intern("take")
  result.rawVal = self.rawVal.funcall(id, 1, n.toRawInt())

iterator items*(self: RubyArray): RawValue =
  ## Iterate over the elements of a ruby Array.
  for i in 0..<self.len():
    yield self[i]
