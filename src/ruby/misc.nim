import ../ruby/[lowlevel, exceptions, types]
import ../ruby/private/utils


proc isNil*(rv: RawValue): bool =
  rv == qNil

proc isBool*(rv: RawValue): bool =
  rv == qTrue or rv == qFalse

proc isUndef*(rv: RawValue): bool =
  rv == qUndef

proc isTruthy*(rv: RawValue): bool =
  rv != qFalse and rv != qNil and rv != qUndef

proc isFalsy*(rv: RawValue): bool =
  not rv.isTruthy

proc isObject*(rv: RawValue): bool =
  getRbType(rv) == tObject

proc isClass*(rv: RawValue): bool =
  getRbType(rv) == tClass

proc isModule*(rv: RawValue): bool =
  getRbType(rv) == tModule

proc isFloat*(rv: RawValue): bool =
  getRbType(rv) == tFloat

proc isString*(rv: RawValue): bool =
  getRbType(rv) == tString

proc isRegexp*(rv: RawValue): bool =
  getRbType(rv) == tRegexp

proc isArray*(rv: RawValue): bool =
  getRbType(rv) == tArray

proc isHash*(rv: RawValue): bool =
  getRbType(rv) == tHash

proc isSymbol*(rv: RawValue): bool =
  getRbType(rv) == tSymbol

proc isInt*(rv: RawValue): bool =
  getRbType(rv) == tFixnum



proc getBool*(rv: RawValue): bool =
  requireType2(rv, [tTrue, tFalse], "bool")
  return rv == qTrue

proc getInt*(rv: RawValue): int =
  requireType2(rv, [tFixnum, tFloat], "int")
  return num2long(rv)

proc getUint*(rv: RawValue): uint =
  requireType2(rv, [tFixnum, tFloat], "uint")
  return num2ulong(rv)

proc getFloat*(rv: RawValue): float =
  requireType2(rv, [tFixnum, tFloat], "float")
  return num2dbl(rv)

proc getString*(rv: RawValue): string =
  requireType(rv, tString, "string")
  let len = rStringLen(rv)
  result = newString(len)
  var data = stringValuePtr(rv)
  copyMem(result.cstring, data, len)
  return result

proc getSymbol*(rv: RawValue): string =
  requireType(rv, tSymbol, "symbol")
  var s = sym2Str(rv)
  var ss = stringValueCstr(s)
  return $ss


proc toRawBool*(value: bool): RawValue =
  if value: qTrue
  else:     qFalse

proc toRawInt*(value: int): RawValue =
  long2num(value)

proc toRawInt*(value: uint): RawValue =
  ulong2num(value)

proc toRawInt*(value: float): RawValue =
  long2num(value.clong)

proc toRawFloat*(value: int): RawValue =
  dbl2num(value.float)

proc toRawFloat*(value: uint): RawValue =
  dbl2num(value.float)

proc toRawFloat*(value: float): RawValue =
  dbl2num(value)

proc toRawStr*(value: string): RawValue =
  strNew(value.cstring, value.len())
  # strNewCstr(value)

proc toRawSym*(value: string): RawValue =
  id2sym(intern(value))


proc setGlobal*(ident: string, value: RubyValue) =
  gvSet(ident, value.rawVal)

proc setGlobal*(ident: string, x: int) =
  gvSet(ident, x.toRawInt())

proc setGlobal*(ident: string, x: float) =
  gvSet(ident, x.toRawFloat())

proc setGlobal*(ident: string, x: string) =
  gvSet(ident, x.toRawStr())

proc setGlobal*(ident: string, x: bool) =
  gvSet(ident, x.toRawBool())



proc getGlobal*(ident: string): RawValue =
  gvGet(ident)


proc className*(value: RubyValue): string =
  var s = objClassName(value.rawVal)
  return $s


proc setInstanceVar*(target: RubyValue, ident: string, value: RubyValue) =
  var realIdent = "@" & ident
  discard target.rawVal.ivSet(realIdent.cstring, value.rawVal)

template setInstanceVar*(target: RubyValue, ident: string, x: int) =
  setInstanceVar(ident, x.toRawInt())

template setInstanceVar*(target: RubyValue, ident: string, x: float) =
  setInstanceVar(ident, x.toRawFloat())

template setInstanceVar*(target: RubyValue, ident: string, x: string) =
  setInstanceVar(ident, x.toRawStr())

template setInstanceVar*(target: RubyValue, ident: string, x: bool) =
  setInstanceVar(ident, x.toRawBool())


proc getInstanceVar*(target: RubyValue, ident: string): RawValue =
  var realIdent = "@" & ident
  result = target.rawVal.ivGet(realIdent.cstring)


proc respondsTo*(self: RubyValue, sym: string): bool =
  var
    id = intern("respond_to?")
    symVal = sym.toRawSym()

  result = self.rawVal.funcall(id, 1, symVal).getBool()

proc inspect*(self: RubyValue): string =
  if not self.respondsTo "inspect":
    raise RubyError.newException("no such method: inspect")

  var id = intern("inspect")
  result = self.rawVal.funcall(id, 0).getString()
