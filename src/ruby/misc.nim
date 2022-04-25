
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# 

import ../ruby/[lowlevel, exceptions, types]
import ../ruby/private/utils


proc isNil*(rv: RawValue): bool =
  ## Returns ``true`` if the RawValue represents Ruby's ``nil`` value.
  rv == qNil

proc isBool*(rv: RawValue): bool =
  ## Returns ``true`` if the RawValue is a Ruby boolean.
  rv == qTrue or rv == qFalse

proc isUndef*(rv: RawValue): bool =
  ## Returns ``true`` if the RawValue is a Ruby ``undefined``. This
  ## doesn't have a representation in the Ruby language, so you
  ## probably won't need it.
  rv == qUndef

proc isTruthy*(rv: RawValue): bool =
  ## Returns `true` for anything besides Ruby ``nil`` and ``false``.
  ## ``if isTruthy(rv): ...`` is the same as ``if rv then ...`` in Ruby.
  rv != qFalse and rv != qNil and rv != qUndef

proc isFalsy*(rv: RawValue): bool =
  ## Negation of ``isTruthy``.
  not rv.isTruthy

proc isObject*(rv: RawValue): bool =
  ## Returns ``true`` for any RawValue that represents an object type.
  getRbType(rv) == tObject

proc isClass*(rv: RawValue): bool =
  ## Returns ``true`` for any RawValue that represents a Ruby class.
  getRbType(rv) == tClass

proc isModule*(rv: RawValue): bool =
  ## Returns ``true`` for any RawValue that represents a Ruby module.
  getRbType(rv) == tModule

proc isFloat*(rv: RawValue): bool =
  ## Returns ``true`` for any RawValue that represents a Ruby float.
  getRbType(rv) == tFloat

proc isString*(rv: RawValue): bool =
  ## Returns ``true`` for any RawValue that represents a Ruby string.
  getRbType(rv) == tString

proc isRegexp*(rv: RawValue): bool =
  ## Returns ``true`` for any RawValue that represents a Ruby regexp.
  getRbType(rv) == tRegexp

proc isArray*(rv: RawValue): bool =
  ## Returns ``true`` for any RawValue that represents a Ruby Array.
  getRbType(rv) == tArray

proc isHash*(rv: RawValue): bool =
  ## Returns ``true`` for any RawValue that represents a Ruby Hash.
  getRbType(rv) == tHash

proc isSymbol*(rv: RawValue): bool =
  ## Returns ``true`` for any RawValue that represents a Ruby symbol.
  getRbType(rv) == tSymbol

proc isInt*(rv: RawValue): bool =
  ## Returns ``true`` for any RawValue that represents a Ruby integer.
  getRbType(rv) == tFixnum



proc getBool*(rv: RawValue): bool =
  ## Convert a RawValue to a Nim bool.
  ## Be careful! If ``rv`` isn't a Ruby boolean, this function
  ## will raise an exception!
  ## See ``isBool``
  requireType2(rv, [tTrue, tFalse], "bool")
  return rv == qTrue

proc getInt*(rv: RawValue): int =
  ## Convert a RawValue to a Nim int.
  ## Be careful! If ``rv`` isn't a Ruby int or float, this function
  ## will raise an exception!
  ## See ``isInt``, ``isFloat``
  requireType2(rv, [tFixnum, tFloat], "int")
  return num2long(rv)

proc getUint*(rv: RawValue): uint =
  ## Convert a RawValue to a Nim uint.
  ## Be careful! If ``rv`` isn't a Ruby int or float, this function
  ## will raise an exception!
  ## See ``isInt``, ``isFloat``
  requireType2(rv, [tFixnum, tFloat], "uint")
  return num2ulong(rv)

proc getFloat*(rv: RawValue): float =
  ## Convert a RawValue to a Nim float.
  ## Be careful! If ``rv`` isn't a Ruby int or float, this function
  ## will raise an exception!
  ## See ``isInt``, ``isFloat``
  requireType2(rv, [tFixnum, tFloat], "float")
  return num2dbl(rv)

proc getString*(rv: RawValue): string =
  ## Convert a RawValue to a Nim float.
  ## Be careful! If ``rv`` isn't a Ruby int or float, this function
  ## will raise an exception!
  ## See ``isInt``, ``isFloat``
  requireType(rv, tString, "string")
  let len = rStringLen(rv)
  result = newString(len)
  var data = stringValuePtr(rv)
  copyMem(result.cstring, data, len)
  return result

proc getSymbol*(rv: RawValue): string =
  ## Convert a RawValue to a Nim string.
  ## Be careful! If ``rv`` isn't a Ruby ``:symbol``, this function
  ## will raise an exception!
  ## See ``isSymbol``
  requireType(rv, tSymbol, "symbol")
  var s = sym2Str(rv)
  var ss = stringValueCstr(s)
  return $ss


proc toRawBool*(value: bool): RawValue =
  ## Convert a Nim ``bool`` to a Ruby boolean.
  if value: qTrue
  else:     qFalse

proc toRawInt*(value: int): RawValue =
  ## Convert a Nim ``int`` to a Ruby integer.
  long2num(value)

proc toRawInt*(value: uint): RawValue =
  ## Convert a Nim ``uint`` to a Ruby integer.
  ulong2num(value)

proc toRawInt*(value: float): RawValue =
  ## Convert a Nim ``float`` to a Ruby integer.
  long2num(value.clong)

proc toRawFloat*(value: int): RawValue =
  ## Convert a Nim ``int`` to a Ruby float.
  dbl2num(value.float)

proc toRawFloat*(value: uint): RawValue =
  ## Convert a Nim ``uint`` to a Ruby float.
  dbl2num(value.float)

proc toRawFloat*(value: float): RawValue =
  ## Convert a Nim ``float`` to a Ruby float.
  dbl2num(value)

proc toRawStr*(value: string): RawValue =
  ## Convert a Nim ``string`` to a Ruby string.
  strNew(value.cstring, value.len())

proc toRawSym*(value: string): RawValue =
  ## Convert a Nim ``string`` to a Ruby symbol.
  id2sym(intern(value))


proc setGlobal*(ident: string, value: RubyValue) =
  ## Set a Ruby global variable to ``value``.
  gvSet(ident, value.rawVal)

proc setGlobal*(ident: string, x: int) =
  ## Set a Ruby global variable to ``x``.
  gvSet(ident, x.toRawInt())

proc setGlobal*(ident: string, x: float) =
  ## Set a Ruby global variable to ``x``.
  gvSet(ident, x.toRawFloat())

proc setGlobal*(ident: string, x: string) =
  ## Set a Ruby global variable to ``x``.
  gvSet(ident, x.toRawStr())

proc setGlobal*(ident: string, x: bool) =
  ## Set a Ruby global variable to ``x``.
  gvSet(ident, x.toRawBool())



proc getGlobal*(ident: string): RawValue =
  ## Get a Ruby global variable.
  gvGet(ident)


proc className*(value: RubyValue): string =
  ## Gets the name of a ``RubyValue``'s class.
  var s = objClassName(value.rawVal)
  return $s


proc setInstanceVar*(target: RubyValue, ident: string, value: RubyValue) =
  ## Set an instance variable of ``target`` to ``value``.
  var realIdent = "@" & ident
  discard target.rawVal.ivSet(realIdent.cstring, value.rawVal)

template setInstanceVar*(target: RubyValue, ident: string, x: int) =
  ## Set an instance variable of ``target`` to ``x``.
  setInstanceVar(ident, x.toRawInt())

template setInstanceVar*(target: RubyValue, ident: string, x: float) =
  ## Set an instance variable of ``target`` to ``x``.
  setInstanceVar(ident, x.toRawFloat())

template setInstanceVar*(target: RubyValue, ident: string, x: string) =
  ## Set an instance variable of ``target`` to ``x``.
  setInstanceVar(ident, x.toRawStr())

template setInstanceVar*(target: RubyValue, ident: string, x: bool) =
  ## Set an instance variable of ``target`` to ``x``.
  setInstanceVar(ident, x.toRawBool())


proc getInstanceVar*(target: RubyValue, ident: string): RawValue =
  ## Get an instance variable of ``target``.
  ## 
  ## .. code-block:: Nim
  ##   # identical to my_var.get_instance_var(:@foo)
  ##   myVar.getInstanceVar("foo")
  ##
  var realIdent = "@" & ident
  result = target.rawVal.ivGet(realIdent.cstring)


proc respondsTo*(self: RubyValue, sym: string): bool =
  ## Equivalent to Ruby's ``respond_to?`` method.
  var
    id = intern("respond_to?")
    symVal = sym.toRawSym()

  result = self.rawVal.funcall(id, 1, symVal).getBool()

proc inspect*(self: RubyValue): string =
  ## Equivalent to Ruby's ``inspect`` method.
  if not self.respondsTo "inspect":
    raise RubyError.newException("no such method: inspect")

  var id = intern("inspect")
  result = self.rawVal.funcall(id, 0).getString()

proc getMethod*(self: RubyValue, sym: string): RawValue =
  ## Equivalent to Ruby's ``method`` method.
  ## 
  ## .. code-block:: Nim
  ##   # identical to my_var.method(:foo)
  ##   myVar.getMethod("foo")
  ##
  if not self.respondsTo "method":
    raise RubyError.newException("no such method: inspect")

  var id = intern("method")
  result = self.rawVal.funcall(id, 1, sym.toRawSym()).getString()
