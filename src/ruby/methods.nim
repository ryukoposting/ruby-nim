
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# 

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
  ## Mark a proc with this macro to make it available as a method of ``RubyObjectType[T]``.
  ## The proc's first argument is the object itself, a ``var T``.
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
  ## And a nice feature:
  ## 
  ## - If you want the name of the Nim proc to be different from the Ruby method's name,
  ##   use the pragma like this: ``{.rbmethod: (RbObjectType, "my_method_name").}``
  ## 
  ## .. code-block:: nim
  ##   import ruby
  ##   type AnObject {.rbmark.} = object
  ##     x, y: int
  ## 
  ##   var RbObject = wrapObjectType[AnObject]("AnObject")
  ##   RbObject.useDefaultAllocator(AnObject)
  ## 
  ##   proc initialize(self: var AnObject, x: int, y: int, message: string): void {.rbmethod: RbObject.} =
  ##     self.x = x
  ##     self.y = y
  ##     echo "initialized! ", message
  ## 
  ##   eval """
  ##   x = AnObject.new(3, 4, "hello world!")
  ##   """
  ##
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
