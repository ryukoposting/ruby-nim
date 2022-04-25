
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# 

import ../ruby/[lowlevel, types]
import ../ruby/private/utils
import std/[macros]

export rbMarkImpl


proc `allocator=`*[T](self: var RubyObjectType[T], rb: RbAllocFunc) =
  ## Set a custom allocator function for this RubyObjectType.
  ## Typically, you won't need to use this. ``useDefaultAllocator``
  ## Should do the job for virtually all use cases.
  self.rawVal.defineAllocFunc(rb)

proc defineMethod*[T](self: var RubyObjectType[T], name: cstring, fn: pointer, nargs: cint) =
  ## Add a new method to the RubyObjectType. ``name`` is the method's
  ## name inside of the Ruby runtime. ``fn`` must point to a function
  ## that takes ``nargs+1`` arguments. The function must be marked with
  ## `{.cdecl.}`, and each argument must have the type `RawValue`.
  ## 
  ## This is called by the output of the ``{.rbmethod.}`` macro.
  self.rawVal.defineMethod(name, fn, nargs)

proc newModule*[T](self: var RubyObjectType[T], name: cstring): RubyModule =
  ## Creates a new module with the given name.
  result.rawVal = defineModuleUnder(self.rawVal, name)

proc includeModule*[T](self: var RubyObjectType[T], module: RubyModule) =
  ## Equivalent to Ruby's ``include <module>``.
  self.rawVal.includeModule(module.rawVal)

proc attrAccessor*[T](self: var RubyObjectType[T], name: string) =
  ## Equivalent to Ruby's ``attr_accessor :name``
  self.rawVal.defineAttr(name.cstring, 1, 1)

proc attrReader*[T](self: var RubyObjectType[T], name: string) =
  ## Equivalent to Ruby's ``attr_reader :name``
  self.rawVal.defineAttr(name.cstring, 1, 0)

proc attrWriter*[T](self: var RubyObjectType[T], name: string) =
  ## Equivalent to Ruby's ``attr_writer :name``
  self.rawVal.defineAttr(name.cstring, 0, 1)

proc getClass*(rv: RubyValue): RubyClass =
  ## Convert any ``RubyValue`` to a ``RubyClass``. Be careful! If
  ## ``rv`` isn't actually a Class object, this function will
  ## raise an exception!
  requireType(rv.rawVal, tClass, "Class")
  result.rawVal = rv.rawVal

proc isInstanceOf*(rv: RubyValue, cls: RubyClass): bool =
  ## Check if ``rv`` is an instance of ``cls``
  objClass(rv.rawVal) == cls.rawVal

proc isInstanceOf*[T](rv: RubyValue, cls: RubyObjectType[T]): bool =
  ## Check if ``rv`` is an instance of ``cls``
  objClass(rv.rawVal) == cls.rawVal

proc unsafeUnpack*[T](self: var RubyObjectType[T], rv: RawValue): ptr T =
  ## Get a pointer to the underling ``T`` object inside a RawValue
  ## whose type is specified by the RubyObjectType ``self``.
  ## 
  ## See examples/classes.nim to see how this function is used.
  var objp: pointer
  TypedData_GetStruct(rv, T, addr self, objp)
  if objp != nil:
    result = cast[ptr T](objp)

proc unpack*[T](objType: var RubyObjectType[T], rv: RawValue, receiver: proc(_: var T): void) =
  ## Similar to ``unsafeUnpack``, but it checks ``rv`` to make sure
  ## it's actually of the type ``objType``. If it is, the underlying
  ## ``T`` inside of ``rv`` is passed to ``receiver`` as a ``var T``.
  if rv.isinstanceOf(objType):
    var objp = unsafeUnpack(objType, rv)
    receiver(objp[])



macro dotOp*(obj: typed, fld: string): untyped =
  ## Turn ``obj.dotOp("fld")`` into ``obj.fld``.
  ## For internal use.
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
  ## Allocates a new ``T`` object, then wraps it inside of a
  ## ``RawValue`` so that the Ruby interpreter can manipulate it.
  ## 
  ## ``useDefaultAllocator`` uses this template.
  var data = allocShared0 sizeof(T)
  return TypedData_Wrap_Struct(self, cast[pointer](dtype), data)


template useDefaultAllocator*(self: untyped, T: typedesc) =
  ## Ruby requires an allocator function to create instances
  ## of custom objects. This template sets an object type's
  ## allocator to a sane default.
  ## 
  ## ``self`` must be a ``RubyObjectType[T]``.
  self.allocator = proc(klass: RawValue): RawValue {.cdecl.} =
    rubyAllocFunc[T](klass, addr self)


proc wrapObjectType*[T](className: string): RubyObjectType[T] =
  ## Creates a new class inside the Ruby interpreter, named
  ## ``className``. When a new instance of this class is created,
  ## Ruby will call the RubyObjectType's allocator (see
  ## ``useDefaultAllocator``) to create the object, then it will
  ## call the ``initialize`` method if one has been defined.
  ## 
  ## ``T`` must be marked with the ``{.rbmark.}`` pragma.
  ## 
  ## This class's ``self`` is a RawValue that wraps a pointer
  ## to a Nim object of type T. This object's lifetime is
  ## managed by Ruby's garbage collector, *not* Nim's garbage
  ## collector. Refer to documentation of ``{.rbmark.}`` for
  ## more details.
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
  ## Same as ``wrapObjectType``, but the class is
  ## defined as a subclass of ``super``.
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
