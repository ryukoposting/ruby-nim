import ../ruby/[lowlevel, types]
import ../ruby/private/utils
import std/[macros]

export rbMarkImpl


proc `allocator=`*[T](self: var RubyObjectType[T], rb: RbAllocFunc) =
  self.rawVal.defineAllocFunc(rb)

proc defineMethod*[T](self: var RubyObjectType[T], name: cstring, fn: pointer, nargs: cint) =
  self.rawVal.defineMethod(name, fn, nargs)

proc newModule*[T](self: var RubyObjectType[T], name: cstring): RubyModule =
  result.rawVal = defineModuleUnder(self.rawVal, name)

proc includeModule*[T](self: var RubyObjectType[T], module: RubyModule) =
  self.rawVal.includeModule(module.rawVal)

proc attrAccessor*[T](self: var RubyObjectType[T], name: string) =
  self.rawVal.defineAttr(name.cstring, 1, 1)

proc attrReader*[T](self: var RubyObjectType[T], name: string) =
  self.rawVal.defineAttr(name.cstring, 1, 0)

proc attrWriter*[T](self: var RubyObjectType[T], name: string) =
  self.rawVal.defineAttr(name.cstring, 0, 1)

proc getClass*(rv: RubyValue): RubyClass =
  requireType(rv.rawVal, tClass, "Class")
  result.rawVal = rv.rawVal

proc isInstanceOf*(rv: RubyValue, cls: RubyClass): bool =
  objClass(rv.rawVal) == cls.rawVal

proc isInstanceOf*[T](rv: RubyValue, cls: RubyObjectType[T]): bool =
  objClass(rv.rawVal) == cls.rawVal

proc unsafeUnpack*[T](self: var RubyObjectType[T], rv: RawValue): ptr T =
  var objp: pointer
  TypedData_GetStruct(rv, T, addr self, objp)
  if objp != nil:
    result = cast[ptr T](objp)

proc unpack*[T](objType: var RubyObjectType[T], rv: RawValue, receiver: proc(_: var T): void) =
  if rv.isinstanceOf(objType):
    var objp = unsafeUnpack(objType, rv)
    receiver(objp[])



macro dotOp*(obj: typed, fld: string): untyped =
  ## Turn ``obj.dotOp("fld")`` into ``obj.fld``.
  newDotExpr(obj, newIdentNode(fld.strVal))


macro doMark(field: untyped): untyped =
  let markImplFunction = ident("rbMarkImpl")
  quote do:
    `markImplFunction`(`field`)


macro xHasCustomPragma2(x: typed, cp: typed{nkSym}): untyped =
  let typ = x.getTypeInst()
  if typ.typeKind == ntyTypeDesc:
    let impl = typ[1].getImpl()
    if impl.kind == nnkNilLit:
      return newLit(false)

  return quote do:
    hasCustomPragma(`x`, `cp`)


macro doRecurse(x: typed): untyped =
  let typ = x.getTypeInst()
  if typ.typeKind == ntyTypeDesc:
    let impl = typ[1].getImpl()
    if impl[2].kind == nnkObjectTy:
      return newLit(true)
  
  return newLit(false)


proc doMarkRecursive(T: typedesc, t: T) =
  for fld, _ in t.fieldPairs:
    when typedesc(t.dotOp(fld)).xHasCustomPragma2(rbmark):
      when typedesc(t.dotOp(fld)).doRecurse():
        doMarkRecursive(typedesc(t.dotOp(fld)), t.dotOp(fld))
      else:
        doMark(t.dotOp(fld))


template rubyAllocFunc*[T](self: RawValue, dtype: untyped) =
  var data = allocShared0 sizeof(T)
  # self[].initializer(data)
  return TypedData_Wrap_Struct(self, cast[pointer](dtype), data)


template useDefaultAllocator*(self: untyped, T: typedesc) =
  self.allocator = proc(klass: RawValue): RawValue {.cdecl.} =
    rubyAllocFunc[T](klass, addr self)


proc wrapObjectType*[T](className: string): RubyObjectType[T] =
  result = RubyObjectType[T]()
  result.rbDataType.wrapStructName = $T
  result.rawVal = qNil
  var t: T

  when not typedesc(t).xHasCustomPragma2(rbmark):
    raise TypeError.newException("initRubyDataType called on a type that was not marked with {.rbmark.}")

  result.rbDataType.function.mark = proc(selfp: pointer) {.cdecl.} =
    # echo "mark"
    var self = cast[ptr T](selfp)
    if isNil(self): return

    for fld, _ in t.fieldPairs:
      when typedesc(t.dotOp(fld)).xHasCustomPragma2(rbmark):
        when typedesc(t.dotOp(fld)).doRecurse():
          doMarkRecursive(typedesc(t.dotOp(fld)), self[].dotOp(fld))
        else:
          doMark(self[].dotOp(fld))

  result.rbDataType.function.size = proc(selfp: pointer): csize_t {.cdecl.} =
    # echo "size"
    return sizeof(T).csize_t

  result.rbDataType.function.free = proc(selfp: pointer) {.cdecl.} =
    deallocShared(selfp)

  result.rawVal = defineClass(className, cObject)



proc wrapObjectTypeUnder*[T](super: RubyValue, className: string): RubyObjectType[T] =
  result = RubyObjectType[T]()
  result.rbDataType.wrapStructName = $T
  result.rawVal = qNil
  var t: T

  when not typedesc(t).xHasCustomPragma2(rbmark):
    raise TypeError.newException("initRubyDataType called on a type that was not marked with {.rbmark.}")

  result.rbDataType.function.mark = proc(selfp: pointer) {.cdecl.} =
    # echo "mark"
    var self = cast[ptr T](selfp)
    if isNil(self): return

    for fld, _ in t.fieldPairs:
      when typedesc(t.dotOp(fld)).xHasCustomPragma2(rbmark):
        when typedesc(t.dotOp(fld)).doRecurse():
          doMarkRecursive(typedesc(t.dotOp(fld)), self[].dotOp(fld))
        else:
          doMark(self[].dotOp(fld))

  result.rbDataType.function.size = proc(selfp: pointer): csize_t {.cdecl.} =
    # echo "size"
    return sizeof(T).csize_t

  result.rbDataType.function.free = proc(selfp: pointer) {.cdecl.} =
    deallocShared(selfp)

  result.rawVal = defineClass(className, super.rawVal)
