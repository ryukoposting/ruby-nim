when not defined(Ruby_LibName):
  when defined(windows):
    const Ruby_LibName* = "libx64-ucrt-ruby(|240|250|260|270|300).dll"
  elif defined(macosx):
    const Ruby_LibName* = "libruby(|-2.4|-2.5|-2.6|-2.7|-3.0).dylib"
  else:
    const Ruby_LibName* = "libruby(|-2.4|-2.5|-2.6|-2.7|-3.0).so"

{.push callConv: cdecl, dynlib: Ruby_LibName.}


template rbmark* {.pragma.}

type
  RawValue* {.rbmark.} = distinct culong
  RawValueSeq* {.rbmark.} = distinct seq[RawValue]
  Id* = distinct culong
  IntPtr = clong
  UintPtr = culong

type
  RubyDataFunc* = proc(self: pointer) {.cdecl, gcsafe.}
  RubyGvarGetter* = proc(id: Id, data: ptr RawValue): RawValue {.cdecl, gcsafe.}
  RubyGvarSetter* = proc(value: RawValue, id: Id, data: ptr RawValue) {.cdecl, gcsafe.}
  RubyGvarMarker* = proc(value: ptr RawValue) {.cdecl, gcsafe.}

  RbAllocFunc* = proc(value: RawValue): RawValue {.cdecl.}

  RBasic* {.importc: "struct RBasic", header: "<ruby/ruby.h>".} = object
    flags* {.importc: "flags".}: RawValue
    klass* {.importc: "klass".}: RawValue

  RData* {.importc: "struct RData", header: "<ruby/ruby.h>".} = object
    basic* {.importc: "basic".}: RBasic
    mark* {.importc: "dmark".}: proc(self: pointer) {.cdecl, gcsafe.}
    free* {.importc: "dfree".}: proc(self: pointer) {.cdecl, gcsafe.}
    data* {.importc: "data".}: pointer

  RbDataTypeFunction* = object
    mark* {.importc: "dmark".}: proc(self: pointer) {.cdecl, gcsafe.}
    free* {.importc: "dfree".}: proc(self: pointer) {.cdecl, gcsafe.}
    size* {.importc: "dsize".}: proc(self: pointer): csize_t {.cdecl, gcsafe.}
    compact* {.importc: "dcompact".}: proc(self: pointer) {.cdecl, gcsafe.}
    reserved {.importc: "reserved".}: array[1, pointer]

  RbDataType* {.importc: "struct rb_data_type_struct", header: "<ruby/ruby.h>".} = object
    wrapStructName* {.importc: "wrap_struct_name".}: cstring
    function* {.importc: "function".}: RbDataTypeFunction
    parent* {.importc: "parent".}: ptr RbDataType
    data {.importc: "data".}: pointer
    flags {.importc: "flags".}: RawValue


const
  RB_NO_KEYWORDS* = cint(0)
  RB_PASS_KEYWORDS* = cint(1)
  RB_PASS_EMPTY_KEYWORDS* = cint(2)
  RB_PASS_CALLED_KEYWORDS* = cint(3)
  RUBY_DEFAULT_FREE* = cast[RubyDataFunc](-1)
  RUBY_NEVER_FREE* = cast[RubyDataFunc](-1)
  RUBY_TYPED_DEFAULT_FREE* = RUBY_DEFAULT_FREE
  RUBY_TYPED_NEVER_FREE* = RUBY_NEVER_FREE


var
  mKernel* {.importc: "rb_mKernel", header: "<ruby/ruby.h>", nodecl.}: RawValue
  mComparable* {.importc: "rb_mComparable", header: "<ruby/ruby.h>", nodecl.}: RawValue
  mEnumerable* {.importc: "rb_mEnumerable", header: "<ruby/ruby.h>", nodecl.}: RawValue
  mErrno* {.importc: "rb_mErrno", header: "<ruby/ruby.h>", nodecl.}: RawValue
  mFileTest* {.importc: "rb_mFileTest", header: "<ruby/ruby.h>", nodecl.}: RawValue
  mGC* {.importc: "rb_mGC", header: "<ruby/ruby.h>", nodecl.}: RawValue
  mMath* {.importc: "rb_mMath", header: "<ruby/ruby.h>", nodecl.}: RawValue
  mProcess* {.importc: "rb_mProcess", header: "<ruby/ruby.h>", nodecl.}: RawValue
  mWaitReadable* {.importc: "rb_mWaitReadable", header: "<ruby/ruby.h>", nodecl.}: RawValue
  mWaitWritable* {.importc: "rb_mWaitWritable", header: "<ruby/ruby.h>", nodecl.}: RawValue

  eRuntimeError* {.importc: "rb_eRuntimeError", header: "<ruby/ruby.h>", nodecl.}: RawValue

  cBasicObject* {.importc: "rb_cBasicObject", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cObject* {.importc: "rb_cObject", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cArray* {.importc: "rb_cArray", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cBinding* {.importc: "rb_cBinding", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cClass* {.importc: "rb_cClass", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cCont* {.importc: "rb_cCont", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cData* {.importc: "rb_cData", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cDir* {.importc: "rb_cDir", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cEncoding* {.importc: "rb_cEncoding", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cEnumerator* {.importc: "rb_cEnumerator", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cFalseClass* {.importc: "rb_cFalseClass", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cFile* {.importc: "rb_cFile", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cComplex* {.importc: "rb_cComplex", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cFloat* {.importc: "rb_cFloat", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cHash* {.importc: "rb_cHash", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cIO* {.importc: "rb_cIO", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cInteger* {.importc: "rb_cInteger", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cMatch* {.importc: "rb_cMatch", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cMethod* {.importc: "rb_cMethod", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cModule* {.importc: "rb_cModule", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cNameErrorMesg* {.importc: "rb_cNameErrorMesg", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cNilClass* {.importc: "rb_cNilClass", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cNumeric* {.importc: "rb_cNumeric", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cProc* {.importc: "rb_cProc", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cRandom* {.importc: "rb_cRandom", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cRange* {.importc: "rb_cRange", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cRational* {.importc: "rb_cRational", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cRegexp* {.importc: "rb_cRegexp", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cStat* {.importc: "rb_cStat", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cStr* {.importc: "rb_cString", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cStruct* {.importc: "rb_cStruct", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cSymbol* {.importc: "rb_cSymbol", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cThread* {.importc: "rb_cThread", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cTime* {.importc: "rb_cTime", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cTrueClass* {.importc: "rb_cTrueClass", header: "<ruby/ruby.h>", nodecl.}: RawValue
  cUnboundMethod* {.importc: "rb_cUnboundMethod", header: "<ruby/ruby.h>", nodecl.}: RawValue

  qNil* {.importc: "RUBY_Qnil", header: "<ruby/ruby.h>", nodecl.}: RawValue
  qTrue* {.importc: "RUBY_Qtrue", header: "<ruby/ruby.h>", nodecl.}: RawValue
  qFalse* {.importc: "RUBY_Qfalse", header: "<ruby/ruby.h>", nodecl.}: RawValue
  qUndef* {.importc: "RUBY_Qundef", header: "<ruby/ruby.h>", nodecl.}: RawValue

  tNone* {.importc: "RUBY_T_NONE", header: "<ruby/ruby.h>", nodecl.}: cint
  tObject* {.importc: "RUBY_T_OBJECT", header: "<ruby/ruby.h>", nodecl.}: cint
  tClass* {.importc: "RUBY_T_CLASS", header: "<ruby/ruby.h>", nodecl.}: cint
  tModule* {.importc: "RUBY_T_MODULE", header: "<ruby/ruby.h>", nodecl.}: cint
  tFloat* {.importc: "RUBY_T_FLOAT", header: "<ruby/ruby.h>", nodecl.}: cint
  tString* {.importc: "RUBY_T_STRING", header: "<ruby/ruby.h>", nodecl.}: cint
  tRegexp* {.importc: "RUBY_T_REGEXP", header: "<ruby/ruby.h>", nodecl.}: cint
  tArray* {.importc: "RUBY_T_ARRAY", header: "<ruby/ruby.h>", nodecl.}: cint
  tHash* {.importc: "RUBY_T_HASH", header: "<ruby/ruby.h>", nodecl.}: cint
  tStruct* {.importc: "RUBY_T_STRUCT", header: "<ruby/ruby.h>", nodecl.}: cint
  tBignum* {.importc: "RUBY_T_BIGNUM", header: "<ruby/ruby.h>", nodecl.}: cint
  tFile* {.importc: "RUBY_T_FILE", header: "<ruby/ruby.h>", nodecl.}: cint
  tData* {.importc: "RUBY_T_DATA", header: "<ruby/ruby.h>", nodecl.}: cint
  tMatch* {.importc: "RUBY_T_MATCH", header: "<ruby/ruby.h>", nodecl.}: cint
  tComplex* {.importc: "RUBY_T_COMPLEX", header: "<ruby/ruby.h>", nodecl.}: cint
  tRational* {.importc: "RUBY_T_RATIONAL", header: "<ruby/ruby.h>", nodecl.}: cint
  tNil* {.importc: "RUBY_T_NIL", header: "<ruby/ruby.h>", nodecl.}: cint
  tTrue* {.importc: "RUBY_T_TRUE", header: "<ruby/ruby.h>", nodecl.}: cint
  tFalse* {.importc: "RUBY_T_FALSE", header: "<ruby/ruby.h>", nodecl.}: cint
  tSymbol* {.importc: "RUBY_T_SYMBOL", header: "<ruby/ruby.h>", nodecl.}: cint
  tFixnum* {.importc: "RUBY_T_FIXNUM", header: "<ruby/ruby.h>", nodecl.}: cint
  tUndef* {.importc: "RUBY_T_UNDEF", header: "<ruby/ruby.h>", nodecl.}: cint
  tImemo* {.importc: "RUBY_T_IMEMO", header: "<ruby/ruby.h>", nodecl.}: cint
  tNode* {.importc: "RUBY_T_NODE", header: "<ruby/ruby.h>", nodecl.}: cint
  tIclass* {.importc: "RUBY_T_ICLASS", header: "<ruby/ruby.h>", nodecl.}: cint
  tZombie* {.importc: "RUBY_T_ZOMBIE", header: "<ruby/ruby.h>", nodecl.}: cint
  tMoved* {.importc: "RUBY_T_MOVED", header: "<ruby/ruby.h>", nodecl.}: cint
  tMask* {.importc: "RUBY_T_MASK", header: "<ruby/ruby.h>", nodecl.}: cint

proc setup*: cint {.importc: "ruby_setup", header: "<ruby/ruby.h>", discardable.}
proc initLoadpath* {.importc: "ruby_init_loadpath", header: "<ruby/ruby.h>", discardable.}
proc cleanup*(_: cint): cint {.importc: "ruby_cleanup", discardable.}

proc require*(_: cstring): RawValue {.importc: "rb_require", header: "<ruby/ruby.h>", discardable.}

proc setScriptName*(name: cstring) {.importc: "ruby_script", discardable.}
proc setScriptName*(value: RawValue) {.importc: "ruby_set_script_name", discardable.}

proc finalize* {.importc: "ruby_finalize", discardable.}
proc stop* {.importc: "ruby_stop", discardable, noReturn.}

proc setStackSize*(_: csize_t) {.importc: "ruby_set_stack_size", discardable.}

proc dbl2num*(num: cdouble): RawValue {.importc: "DBL2NUM", header: "<ruby/ruby.h>", nodecl, discardable.}
proc long2num*(num: clong): RawValue {.importc: "LONG2NUM", header: "<ruby/ruby.h>", nodecl, discardable.}
proc ulong2num*(num: culong): RawValue {.importc: "ULONG2NUM", header: "<ruby/ruby.h>", nodecl, discardable.}

proc strNew*(str: pointer, length: clong): RawValue {.importc: "rb_str_new", discardable.}
proc strNewCstr*(str: cstring): RawValue {.importc: "rb_str_new_cstr", discardable.}

proc num2dbl*(value: RawValue): cdouble {.importc: "NUM2DBL", header: "<ruby/ruby.h>", nodecl, discardable.}
proc num2long*(value: RawValue): clong {.importc: "NUM2LONG", header: "<ruby/ruby.h>", nodecl, discardable.}
proc num2ulong*(value: RawValue): culong {.importc: "NUM2ULONG", header: "<ruby/ruby.h>", nodecl, discardable.}

proc stringValueCstr*(value: RawValue): cstring {.importc: "StringValueCStr", header: "<ruby/ruby.h>", nodecl, discardable.}
proc stringValuePtr*(value: RawValue): pointer {.importc: "StringValuePtr", header: "<ruby/ruby.h>", nodecl, discardable.}
proc rstringLen*(value: RawValue): clong {.importc: "RSTRING_LEN", header: "<ruby/ruby.h>", nodecl, discardable.}


proc evalString*(code: cstring): RawValue {.importc: "rb_eval_string", discardable.}
proc evalStringProtect*(code: cstring, status: ptr cint): RawValue {.importc: "rb_eval_string_protect", discardable.}
proc rbProtectInner*(fn: pointer, arg: RawValue, state: ptr cint): RawValue {.importc: "rb_protect", discardable.}
proc rbRescue*(fn: pointer, arg: RawValue, rescuefn: pointer, rescueArg: RawValue): RawValue {.importc: "rb_rescue", discardable.}
proc rbEnsure*(fn: pointer, arg: RawValue, ensurefn: pointer, ensureArg: RawValue): RawValue {.importc: "rb_ensure", discardable.}

proc rbRaise*(exc: RawValue, fmt: cstring) {.importc: "rb_raise", header: "<ruby/ruby.h>", varargs, discardable.}

proc rbProtect*(fn: pointer, arg: pointer, state: ptr cint): RawValue =
  rbProtectInner(fn, cast[RawValue](arg), state)

proc funcall*(recv: RawValue, id: Id, nargs: cint): RawValue {.importc: "rb_funcall", varargs, discardable.}
proc funcallv*(recv: RawValue, id: Id, argc: cint, argv: ptr RawValue): RawValue {.importc: "rb_funcallv", discardable.}
proc funcallvKw*(recv: RawValue, id: Id, argc: cint, argv: ptr RawValue, flags: cint): RawValue {.importc: "rb_funcallv_kw", discardable.}
proc funcallvPublic*(recv: RawValue, id: Id, argc: cint, argv: ptr RawValue): RawValue {.importc: "rb_funcallv_public", discardable.}
proc funcallvPublicKw*(recv: RawValue, id: Id, argc: cint, argv: ptr RawValue, flags: cint): RawValue {.importc: "rb_funcallv_public_kw", discardable.}
proc funcallPassingBlock*(recv: RawValue, id: Id, argc: cint, argv: ptr RawValue): RawValue {.importc: "rb_funcall_passing_block", discardable.}
proc funcallPassingBlockKw*(recv: RawValue, id: Id, argc: cint, argv: ptr RawValue, flags: cint): RawValue {.importc: "rb_funcall_passing_block_kw", discardable.}
proc funcallWithBlock*(recv: RawValue, id: Id, argc: cint, argv: ptr RawValue, bloc: RawValue): RawValue {.importc: "rb_funcall_with_block", discardable.}
proc funcallWithBlockKw*(recv: RawValue, id: Id, argc: cint, argv: ptr RawValue, bloc: RawValue, flags: cint): RawValue {.importc: "rb_funcall_with_block_kw", discardable.}



proc errInfo*: RawValue {.importc: "rb_errinfo", discardable.}
proc setErrInfo*(errInfo: RawValue): void {.importc: "rb_set_errinfo", header: "<ruby/ruby.h>", nodecl, discardable.}



proc newobj*: RawValue {.importc: "rb_newobj", discardable.}
proc newobj_of*(klass: RawValue; flags: RawValue): RawValue {.importc: "rb_newobj_of", discardable.}
proc obj_setup*(obj: RawValue, klass: RawValue, tyype: RawValue): RawValue {.importc: "rb_obj_setup", discardable.}
proc obj_hide*(obj: RawValue): RawValue {.importc: "rb_obj_hide", discardable.}



# proc dataObjectWrap*(klass: RawValue, sVal: pointer, mark: RubyDataFunc, free: RubyDataFunc): RawValue {.importc: "rb_data_object_wrap", discardable.}
# proc dataObjectZalloc*(klass: RawValue,size: csize_t, mark: RubyDataFunc, free: RubyDataFunc): RawValue {.importc: "rb_data_object_zalloc", discardable.}
# proc dataTypedObjectWrap*(klass: RawValue, sVal: pointer, dataType: RbDataType): RawValue {.importc: "rb_data_typed_object_wrap", discardable.}
# proc dataTypedObjectZalloc*(klass: RawValue, size: csize_t, dataType: RbDataType): RawValue {.importc: "rb_data_typed_object_zalloc", discardable.}
proc defineAllocFunc*(klass: RawValue, fn: RbAllocFunc) {.importc: "rb_define_alloc_func", header: "<ruby/ruby.h>".}
proc defineAttr*(klass: RawValue, name: cstring, gettable: cint, settable: cint) {.importc: "rb_define_attr", header: "<ruby/ruby.h>".}

proc gvSet*(name: cstring, value: RawValue): RawValue {.importc: "rb_gv_set", discardable.}
proc gvGet*(name: cstring): RawValue {.importc: "rb_gv_get", discardable.}
proc ivGet*(target: RawValue, name: cstring): RawValue {.importc: "rb_iv_get", discardable.}
proc ivSet*(target: RawValue, name: cstring, value: RawValue): RawValue {.importc: "rb_iv_set", discardable.}


proc defineClass*(name: cstring, super: RawValue): RawValue {.importc: "rb_define_class", discardable.}
proc defineModule*(name: cstring): RawValue {.importc: "rb_define_module", discardable.}
proc defineClassUnder*(parentClass: RawValue, name: cstring, super: RawValue): RawValue {.importc: "rb_define_class_under", discardable.}
proc defineModuleUnder*(parentClass: RawValue, name: cstring): RawValue {.importc: "rb_define_module_under", discardable.}

proc defineVariable*(name: cstring, targ: ptr RawValue) {.importc: "rb_define_variable", discardable.}
proc defineVirtualVariable*(name: cstring, getter: RubyGvarGetter, setter: RubyGvarSetter) {.importc: "rb_define_virtual_variable", discardable.}
proc defineHookedVariable*(name: cstring, varr: ptr RawValue, getter: RubyGvarGetter, setter: RubyGvarSetter) {.importc: "rb_define_hooked_variable", discardable.}
proc defineReadonlyVariable*(name: cstring, varr: ptr RawValue) {.importc: "rb_define_readonly_variable", discardable.}
proc defineConst*(klass: RawValue, name: cstring, value: RawValue) {.importc: "rb_define_const", discardable.}
proc defineGlobalConst*(name: cstring, value: RawValue) {.importc: "rb_define_global_const", discardable.}

proc undefineMethod*(klass: RawValue, name: cstring) {.importc: "rb_undef_method", discardable.}
proc defineMethod*(klass: RawValue, name: cstring, fn: pointer, nargs: cint) {.importc: "rb_define_method", discardable.}
# proc defineMethod*(klass: RawValue, name: cstring, fn: proc(_: RawValue): RawValue {.cdecl.}, nargs: cint) {.importc: "rb_define_method", discardable.}
proc defineModuleFunction*(classmodule: RawValue, name: cstring, fn: pointer, nargs: cint) {.importc: "rb_define_module_function", discardable.}
proc defineGlobalFunction*(name: cstring, fn: pointer, nargs: cint) {.importc: "rb_define_global_function", discardable.}

proc includeModule*(klass: RawValue, module: RawValue) {.importc: "rb_include_module", discardable.}
proc extendObject*(obj: RawValue, module: RawValue): RawValue {.importc: "rb_extend_object", discardable.}
# proc prependModule*(_: RawValue, _: RawValue): RawValue {.importc: "rb_prepend_module", discardable.}

proc class2Name*(klass: RawValue): cstring {.importc: "rb_class2name", discardable.}
proc objClassName*(obj: RawValue): cstring {.importc: "rb_obj_classname", discardable.}
proc objClass*(obj: RawValue): RawValue {.importc: "rb_obj_class", discardable.}



proc intern*(name: cstring): Id {.importc: "rb_intern", discardable.}
proc intern2*(name: ptr cchar, length: clong): Id {.importc: "rb_intern2", discardable.}
proc internStr*(strValue: RawValue): Id {.importc: "rb_intern_str", discardable.}
proc id2Name*(id: Id): cstring {.importc: "rb_id2name", discardable.}
# proc checkId*(_: *mut VALUE): Id {.importc: "rb_check_id", discardable.}
proc toId*(value: RawValue): Id {.importc: "rb_to_id", discardable.}
proc sym2Id*(sym: RawValue): Id {.importc: "rb_sym2id", discardable.}
proc id2Str*(id: Id): RawValue {.importc: "rb_id2str", discardable.}
proc sym2Str*(sym: RawValue): RawValue {.importc: "rb_sym2str", discardable.}
proc toSymbol*(name: RawValue): RawValue {.importc: "rb_to_symbol", discardable.}
proc checkSymbol*(namep: ptr RawValue): RawValue {.importc: "rb_check_symbol", discardable.}
proc id2Sym*(id: Id): RawValue {.importc: "rb_id2sym", discardable.}


proc getRbType*(raw: RawValue): cint {.importc: "rb_type", header: "<ruby/ruby.h>", discardable, nodecl.}


proc aryEntry*(raw: RawValue, index: clong): RawValue {.importc: "rb_ary_entry", header: "<ruby/ruby.h>", discardable.}
proc aryLength*(raw: RawValue): clong {.importc: "RARRAY_LEN", header: "<ruby/ruby.h>", nodecl, discardable.}


proc hashARef*(raw: RawValue, key: RawValue): RawValue {.importc: "rb_hash_aref", header: "<ruby/ruby.h>", discardable.}
proc hashASet*(raw: RawValue, key: RawValue, value: RawValue): RawValue {.importc: "rb_hash_aset", header: "<ruby/ruby.h>", discardable.}


proc rbMarkImpl*(raw: RawValue) {.importc: "rb_gc_mark", discardable.}
proc rbMarkImpl*(raw: RawValueSeq) =
  for val in cast[seq[RawValue]](raw):
    rbMarkImpl(val)


template RUBY_INIT_STACK* =
  {.emit: ["RUBY_INIT_STACK;"].}

proc TypedData_Wrap_Struct*(clazz: RawValue, dataType: pointer, sval: pointer): RawValue {.importc, header: "<ruby/ruby.h>", nodecl, inline.}

template TypedData_GetStruct*(raw: RawValue, T: typedesc, dataType: pointer, sval: var pointer) =
  {.emit: ["TypedData_Get_Struct(", raw, ", ", T, ", ", dataType, ", ", sval, ");"] .}

proc `==`*(x, y: RawValue): bool =
  cast[culong](x) == cast[culong](y)
