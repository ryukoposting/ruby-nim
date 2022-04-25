
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# 

import ../ruby/[lowlevel]
import ../ruby/private/utils
import std/macros


proc generateWrapperProc*(body: NimNode, prefix="rubyGlobalProc_"): NimNode =
  let rawValueSym = ident("RawValue")
  let innerProcIdent = body[0]
  let methodProcIdent = ident getWrapperProcName(body, prefix)
  let nargs = getProcNargs(body)

  var formalParams = nnkFormalParams.newNimNode(body)

  formalParams.add rawValueSym
  for i in 0..nargs:
    var argDef = nnkIdentDefs.newNimNode(body)
    argDef.add ident("arg" & $i)
    argDef.add rawValueSym
    argDef.add newEmptyNode()
    formalParams.add argDef
  
  result = quote do:
    proc `methodProcIdent`(): RawValue {.cdecl.} =
      let callResult = `innerProcIdent`()
      return callResult

  
  result[3] = formalParams # set proc wrapper's formalparams

  # TODO add call args to result[^1][^2][0][^1]
  for i in 1..nargs: # 0 is return type, so start at 1
    let
      argDef = body[3][i]
      argTypename = $argDef[1]
      argIdent = ident("arg" & $i)
    # echo $argIdent, " ", argTypename
    
    var argConversionExpr: NimNode

    case argTypename
    of "bool":
      argConversionExpr = newCall("getBool", argIdent)
    of "int":
      argConversionExpr = newCall("getInt", argIdent)
    of "float":
      argConversionExpr = newCall("getFloat", argIdent)
    of "string":
      argConversionExpr = newCall("getString", argIdent)
    of "RubyHash":
      argConversionExpr = newCall("getHash", argIdent)
    of "RubyArray":
      argConversionExpr = newCall("getArray", argIdent)
    of "RubyObject":
      argConversionExpr = newCall("getObject", argIdent)
    of "RawValue":
      argConversionExpr = argIdent
    else:
      error("invalid ruby method arg type: " & argTypename, argDef)
    
    result[^1][^2][0][^1].add argConversionExpr


  let retTypename = $body[3][0]
  let resultId = result[^1][^1][^1]
  case retTypename
  of "bool":
    result[^1][^1][^1] = newCall("toRawBool", resultId)
  of "int":
    result[^1][^1][^1] = newCall("toRawInt", resultId)
  of "float":
    result[^1][^1][^1] = newCall("toRawFloat", resultId)
  of "string":
    result[^1][^1][^1] = newCall("toRawStr", resultId)
  of "RawValue":
    discard # RawValue can be returned directly
  of "void":
    result[^1][^2] = result[^1][^2][0][2]
    # result[^1][^3][3][0] = newEmptyNode()
    result[^1][^1][^1] = ident("qNil")
  else:
    error("invalid ruby method return type: " & $retTypeName, body[3][0])


proc generateGlobalProcDef(body: NimNode, prefix="rubyGlobalProc_"): NimNode =
  let
    methodProcIdent = ident getWrapperProcName(body, prefix)
    nargs = newIntLitNode(getProcNargs(body))
    innerProcIdent = body[0].toStrLit

  result = quote do:
    defineGlobalFunction(`innerProcIdent`, `methodProcIdent`, `nargs`)


macro rbproc*(body: untyped): untyped =
  ## Mark a proc with this macro to make it available inside of ruby.
  ## The proc can take any of the following argument types:
  ## 
  ## - ``RawValue``
  ## - Basic types: ``int``, ``bool``, ``float``, ``string``
  ## - Ruby types: ``RubyHash``, ``RubyArray``, ``RubyObject``
  ## 
  ## The proc can return any of the following types:
  ## - ``RawValue``
  ## - ``void``
  ## - Basic types: ``int``, ``bool``, ``float``, ``string``
  ## 
  ## A few gotchas:
  ## 
  ## - This macro expects each argument to have its type specified separately.
  ##   In other words, the macro doesn't know what to do with ``proc myfunc(x, y, z: int)``
  ##   but it will handle ``proc myfunc(x: int, y: int, z: int)`` just fine.
  ## 
  ## - This macro expects an explicit return type, even for a proc returning void.
  ## 
  ## .. code-block:: nim
  ##   proc my_nim_function(x: int, y: int): int {.rbproc.} =
  ##     echo "Hello from Nim!"
  ##     return x + y
  ## 
  ##   assert eval("my_nim_function(2, 3)").getInt() == 5
  result = newStmtList(
    body,
    generateWrapperProc(body),
    generateGlobalProcDef(body)
  )
