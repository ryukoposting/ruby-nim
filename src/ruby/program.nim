import std/[macros, strutils]
import ../ruby/private/utils

proc rubyExpr(ast: NimNode): string =
  requireKind ast, [nnkIntLit, nnkFloatLit, nnkStrLit]
  case ast.kind:
  of nnkIntLit, nnkFloatLit: result = ast.toStrLit().strVal
  of nnkStrLit: result = escape($ast, prefix="'", suffix="'")
  else:
    error "internal error", ast

proc rubyAsgn(ast: NimNode): string =
  requireKind ast, [nnkAsgn]
  let
    assignee = ast[0]
    value = ast[1]
  
  requireKind assignee, [nnkIdent, nnkPrefix]
  if assignee.kind == nnkPrefix:
    requireKind assignee[0], [nnkIdent]
    requireKind assignee[1], [nnkIdent]

  if assignee.kind == nnkIdent:
    return $assignee & " = " & rubyExpr(value)
  elif $assignee[0] == "@":
    return "@" & $assignee[1] & " = " & rubyExpr(value)
  elif $assignee[0] == "$":
    return "$" & $assignee[1] & " = " & rubyExpr(value)
  else:
    error "invalid prefixOperator in assignee", assignee

proc rubyStmtList(body: NimNode): string =
  requireKind body, [nnkStmtList]

  for child in body.children:
    requireKind child, [nnkAsgn]
    result.add "\n"

    result.add case child.kind:
      of nnkAsgn: rubyAsgn child
      else:
        error "internal error", child
        ""

macro rubyCode*(body: untyped): untyped =
  echo body.treeRepr

  let code = rubyStmtList(body)

  result = quote do:
    ruby.eval(`code`)
  
  echo result.treeRepr
