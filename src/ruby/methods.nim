import ../ruby/[lowlevel, class]
import ../ruby/private/utils
import std/macros

proc generateWrapperMethod(parent, body: NimNode, prefix: string): NimNode =
  let rawValueSym = ident("RawValue")
  let objTypeDesc = ident($parent.getTypeInst()[1])
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
  let self = nskVar.genSym "self"

  result = quote do:
    proc `methodProcIdent`(): RawValue {.cdecl.} =
      var selfp: pointer
      TypedData_GetStruct(`arg0`, `objTypeDesc`, addr `parent`, selfp)
      var `self` = cast[ptr `objTypeDesc`](selfp)

      let callResult = `innerProcIdent`(`self`[])

      return callResult
  
  recursiveCopyLineInfo(result, body)

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


proc generateMethodDef(parent, body: NimNode, prefix: string, methodName: NimNode): NimNode =
  let methodProcIdent = ident getWrapperProcName(body, prefix)
  let nargs = newIntLitNode(getProcNargs(body) - 1)
  # let innerProcIdent = body[0].toStrLit

  result = quote do:
    defineMethod(`parent`, `methodName`, `methodProcIdent`, `nargs`)


macro rbmethod*(parent: typed, body: untyped): untyped =
  # echo $parent.kind, " ", $body.kind
  let parentId =
    if parent.kind == nnkSym:
      parent
    else:
      parent[0]

  let methodName =
    if parent.kind == nnkSym:
      body[0].toStrLit
    else:
      parent[1]
  
  # echo $methodName

  let wrapperPrefix = $parentId & "_"
  result = newStmtList(
    body,
    generateWrapperMethod(parentId, body, wrapperPrefix),
    generateMethodDef(parentId, body, wrapperPrefix, methodName)
  )
