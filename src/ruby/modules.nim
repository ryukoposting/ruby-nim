
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# 

import ../ruby/[lowlevel, globals, types]
import ../ruby/private/utils
import macros


proc newModule*(name: string): RubyModule =
  result.rawVal = defineModule(name)

proc getModule*(raw: RawValue): RubyModule =
  requireType(raw, tModule, "Module")
  result.rawVal = raw

proc defineProc*(self: var RubyModule, name: cstring, fn: pointer, nargs: cint) =
  self.rawVal.defineModuleFunction(name, fn, nargs)

proc defineMethod*(self: var RubyModule, name: cstring, fn: pointer, nargs: cint) =
  self.rawVal.defineMethod(name, fn, nargs)




proc generateWrapperModuleMethod(parent, body: NimNode, prefix: string): NimNode =
  let rawValueSym = ident("RawValue")
  # let objTypeDesc = ident($parent.getTypeInst()[1])
  let innerProcIdent = body[0]
  let methodProcIdent = ident getWrapperProcName(body, prefix)
  let nargs = getProcNargs(body)

  var formalParams = nnkFormalParams.newNimNode(body)

  formalParams.add rawValueSym
  for i in 0..<nargs:
    var argDef = nnkIdentDefs.newNimNode(body)
    argDef.add ident("arg" & $i)
    argDef.add rawValueSym
    argDef.add newEmptyNode()
    formalParams.add argDef
  
  let arg0 = ident "arg0"
  # let self = nskVar.genSym "self"

  result = quote do:
    proc `methodProcIdent`(): RawValue {.cdecl.} =
      # var selfp: pointer
      # TypedData_GetStruct(`arg0`, `objTypeDesc`, addr `parent`, selfp)
      # var `self` = cast[ptr `objTypeDesc`](selfp)

      let callResult = `innerProcIdent`(`arg0`)

      return callResult

  
  result[3] = formalParams # set proc wrapper's formalparams

  # TODO add call args to result[^1][^2][0][^1]
  for i in 2..nargs: # 0 is return type, 1 is self, so start at 2
    let
      argDef = body[3][i]
      argTypename = $argDef[1]
      argIdent = ident("arg" & $(i - 1))
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


  # TODO replace result[^1][^1][^1] with wrapped result value
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
    result[^1][^1][^1] = arg0
  else:
    error("invalid ruby method return type: " & $retTypeName, body[3][0])




proc generateModuleProcDef(parent, body: NimNode, prefix: string): NimNode =
  let
    methodProcIdent = ident getWrapperProcName(body, prefix)
    nargs = newIntLitNode(getProcNargs(body))
    innerProcIdent = body[0].toStrLit

  result = quote do:
    defineProc(`parent`, `innerProcIdent`, `methodProcIdent`, `nargs`)

proc generateModuleMethodDef(parent, body: NimNode, prefix: string): NimNode =
  let methodProcIdent = ident getWrapperProcName(body, prefix)
  let nargs = newIntLitNode(getProcNargs(body) - 1)
  let innerProcIdent = body[0].toStrLit

  result = quote do:
    defineMethod(`parent`, `innerProcIdent`, `methodProcIdent`, `nargs`)



macro rbModuleProc*(parent, body: untyped) =
  let wrapperPrefix = $parent & "_p_"
  result = newStmtList(
    body,
    generateWrapperProc(body, wrapperPrefix),
    generateModuleProcDef(parent, body, wrapperPrefix)
  )

macro rbModuleMethod*(parent, body: untyped) =
  let wrapperPrefix = $parent & "_m_"
  result = newStmtList(
    body,
    generateWrapperModuleMethod(parent, body, wrapperPrefix),
    generateModuleMethodDef(parent, body, wrapperPrefix)
  )
