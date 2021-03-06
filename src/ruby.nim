## Nim bindings to libruby, the library backing Matz's
## Ruby Interpreter (MRI).
## 
## libruby's C API can be directly accessed using the
## `ruby/lowlevel` module. The rest of this package
## provides high-level abstractions over the C API.

# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# 

import ruby/[lowlevel, types, class, methods, globals, modules, misc, exceptions, objects, arrays, hashes, calls, regexp]

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

# regexp
export regexp


proc initRuby* =
  ## Initialize the Ruby runtime. This must be called before
  ## doing *anything* else with Ruby!
  when defined(windows):
    # On windows, ruby_sysinit calls rb_w32_sysinit, which sets up
    # critical parts of the execution environment. ruby_sysinit
    # is not mission-critical on any other platform, as far as I
    # can tell.
    var
      fakeArgc {.global.}: cint = 0
      fakeArgv {.global.}: array[1, ptr cchar]
    rubySysInit(addr fakeArgc, cast[ptr ptr ptr cchar](addr fakeArgv))
  setup()
  initLoadpath()

proc cleanupRuby* =
  ## Cleans up the Ruby runtime. This causes (pretty much) all
  ## resources used by Ruby to be freed. Ruby cannot be
  ## re-initialized after this function is called.
  cleanup(0)

proc eval*(rubyCode: string): RawValue =
  ## Evaluate some Ruby code.
  var status: cint = 0

  block:
    var err = errInfo()
    if err != qNil:
      setErrInfo(qNil)
      raise newRubyError(err)

  result = evalStringProtect(rubyCode.cstring, addr status)

  if status != 0:
    var err = errInfo()
    setErrInfo(qNil)
    raise newRubyError(err)

proc require*(path: string): RawValue =
  ## `require`s a Ruby file. This maps directly to Ruby's
  ## `require` statement.
  require(cstring(path))

proc setScriptName*(name: string) =
  setScriptName(cstring(name))

template sym*(symname: static string): RawValue =
  ## Abbreviated version of ``toRawSym()``
  symname.toRawSym()
