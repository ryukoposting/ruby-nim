# This is just an example to get you started. A typical library package
# exports the main API in this file. Note that you cannot rename this file
# but you can remove it if you wish.

import ruby/[lowlevel, types, class, methods, globals, modules, misc, exceptions, objects, arrays, hashes, calls]

# lowlevel
# export lowlevel
export RawValue, rbmark, qNil

# types
export types

# class
export wrapObjectType, `allocator=`, defineMethod, useDefaultAllocator
export newModule, includeModule, isInstanceOf, getClass, wrapObjectTypeUnder
export attrAccessor, attrReader, attrWriter, call, unpack, unsafeUnpack

# methods
export rbmethod

# global functions
export rbproc

# exceptions
export RubyError, raiseRubyError

# misc
export misc

# modules
export newModule, defineProc, rbmoduleproc, rbmodulemethod

# objects
export objects

# arrays
export arrays

# hashes
export hashes

# calls
export calls


template initRuby* =
  setup()
  initLoadpath()

template cleanupRuby* =
  cleanup(0)

proc eval*(rubyCode: string): RawValue =
  var status: cint = 0

  block:
    var err = errInfo()
    if err != qNil:
      setErrInfo(qNil)
      raise newRubyError(err)

  result = evalStringProtect(rubyCode, addr status)

  if status != 0:
    var err = errInfo()
    setErrInfo(qNil)
    raise newRubyError(err)

proc require*(path: string): RawValue =
  require(cstring(path))

proc setScriptName*(name: string) =
  setScriptName(cstring(name))
