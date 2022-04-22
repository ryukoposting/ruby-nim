import std/[macros, strformat]
import ../../ruby/[lowlevel, exceptions]

proc getProcNargs*(body: NimNode): int =
  let formalParams = body[3]
  assert formalParams.kind == nnkFormalParams
  result = len(formalParams) - 1


proc requireKind*(node: NimNode, kind: openArray[NimNodeKind]) =
  if not kind.contains(node.kind):
    error "invalid node kind (expected " & $kind & ")", node


proc type2str*(rv: RawValue): string =
  let typ = getRbType(rv)
  if tNone == typ:
    "None"
  elif tObject == typ:
    "Object"
  elif tClass == typ:
    "Class"
  elif tModule == typ:
    "Module"
  elif tFloat == typ:
    "Float"
  elif tString == typ:
    "String"
  elif tRegexp == typ:
    "Regexp"
  elif tArray == typ:
    "Array"
  elif tHash == typ:
    "Hash"
  elif tStruct == typ:
    "Struct"
  elif tBignum == typ:
    "Bignum"
  elif tFile == typ:
    "File"
  elif tData == typ:
    "Data"
  elif tMatch == typ:
    "Match"
  elif tComplex == typ:
    "Complex"
  elif tRational == typ:
    "Rational"
  elif tNil == typ:
    "Nil"
  elif tTrue == typ:
    "True"
  elif tFalse == typ:
    "False"
  elif tSymbol == typ:
    "Symbol"
  elif tFixnum == typ:
    "Fixnum"
  elif tUndef == typ:
    "Undef"
  elif tImemo == typ:
    "Imemo"
  elif tNode == typ:
    "Node"
  elif tIclass == typ:
    "Iclass"
  elif tZombie == typ:
    "Zombie"
  elif tMoved == typ:
    "Moved"
  elif tMask == typ:
    "Mask"
  else:
    raise ValueError.newException("unknown type passed to type2str")


template requireType*(rv: RawValue, typ: cint, desiredType: string) =
  if getRbType(rv) != typ:
    raise newRubyError("cannot convert RawValue (type " & type2str(rv) & ") to " & desiredType)


template requireType2*(rv: RawValue, typ: openArray[cint], desiredType: string) =
  if not typ.contains(getRbType(rv)):
    raise newRubyError("cannot convert RawValue (type " & type2str(rv) & ") to " & desiredType)


proc getWrapperProcName*(body: NimNode, prefix: string): string =
  let methodName = $body[0]
  result = prefix & methodName

proc recursiveCopyLineInfo*(dest, info: NimNode) =
  copyLineInfo(dest, info)
  for child in dest.children:
    recursiveCopyLineInfo(child, info)
