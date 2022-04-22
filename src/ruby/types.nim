import ../ruby/lowlevel

type
  RubyValue* = concept x
    x.rawVal is RawValue

  RubyObject* = object
    rawVal*: RawValue

  RubyModule* = object
    rawVal*: RawValue

  RubyObjectType*[T] = object
    rbDataType*: RbDataType
    rawVal*: RawValue

  RubyClass* = object
    rawVal*: RawValue

  RubyArray* = object
    rawVal*: RawValue

  RubyHash* = object
    rawVal*: RawValue

func `rawVal`* (rv: RawValue): RawValue = rv
