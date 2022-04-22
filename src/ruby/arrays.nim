import ../ruby/[lowlevel, types, misc]
import ../ruby/private/utils


proc getArray*(raw: RubyValue): RubyArray =
  requireType(raw.rawVal, tArray, "RubyArray")
  result.rawVal = raw


proc `[]`*(self: RubyArray, index: int): RawValue =
  self.rawVal.aryEntry(index)


proc len*(self: RubyArray): int =
  self.rawVal.aryLength()


proc toSeq*(self: RubyArray): seq[RawValue] =
  result = @[]
  for i in 0..<self.len():
    result.add self[i]


proc map*(self: RubyArray, bloc: RubyValue): RubyArray =
  var id = intern("map")
  result.rawVal = self.rawVal.funcallWithBlock(id, 0, nil, bloc.rawVal)


proc select*(self: RubyArray, bloc: RubyValue): RubyArray =
  var id = intern("select")
  result.rawVal = self.rawVal.funcallWithBlock(id, 0, nil, bloc.rawVal)


proc sort*(self: RubyArray, bloc: RubyValue): RubyArray =
  var id = intern("sort")
  result.rawVal = self.rawVal.funcallWithBlock(id, 0, nil, bloc.rawVal)


proc sort*(self: RubyArray): RawValue =
  var id = intern("sort")
  result = self.rawVal.funcall(id, 0)


proc shift*(self: RubyArray): RawValue =
  var id = intern("shift")
  result = self.rawVal.funcall(id, 0)


proc push*(self: RubyArray, value: RubyValue): RawValue =
  var id = intern("push")
  result = self.rawVal.funcall(id, 1, value.rawVal)


proc sum*(self: RubyArray): RawValue =
  var id = intern("sum")
  result = self.rawVal.funcall(id, 0)


proc take*(self: RubyArray, n: int): RubyArray =
  var id = intern("take")
  result.rawVal = self.rawVal.funcall(id, 1, n.toRawInt())


iterator items*(self: RubyArray): RawValue =
  for i in 0..<self.len():
    yield self[i]
