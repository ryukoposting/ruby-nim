import std/strformat
import ../ruby/lowlevel

type
  RubyError* = object of ValueError
    backtrace*: seq[string]
  
  # RubyNoMemoryError* = object of RubyError

  # RubyScriptError* = object of RubyError
  # RubyLoadError* = object of RubyScriptError
  # RubyNotImplementedError* = object of RubyScriptError
  # RubySyntaxError* = object of RubyScriptError

  # RubySecurityError* = object of RubyError

  # RubySignalException* = object of RubyError
  # RubyInterrupt* = object of RubySignalException

  # RubyStandardError* = object of RubyError
  # RubyArgumentError* = object of RubyStandardError
  # RubyUncaughtThrowError* = object of RubyArgumentError
  # RubyEncodingError* = object of RubyStandardError
  # RubyFiberError* = object of RubyStandardError
  # RubyIoError* = object of RubyStandardError
  # RubyEofError* = object of RubyIoError
  # RubyIndexError* = object of RubyStandardError
  # RubyKeyError*  = object of RubyIndexError
  # RubyStopIteration*  = object of RubyIndexError
  # RubyLocalJumpError* = object of RubyStandardError
  # RubyNameError* = object of RubyStandardError
  # RubyNoMethodError* = object of RubyNameError
  # RubyRangeError* = object of RubyStandardError
  # RubyFloatDomainError* = object of RubyRangeError
  # RubyRegexpError* = object of RubyStandardError
  # RubyRuntimeError* = object of RubyStandardError
  # RubyFrozenError* = object of RubyRuntimeError
  # RubySystemCallError* = object of RubyStandardError
  # RubyThreadError* = object of RubyStandardError
  # RubyTypeError* = object of RubyStandardError
  # RubyZeroDivisionError* = object of RubyStandardError

  # RubySystemExit* = object of RubyError

  # RubySystemStackError* = object of RubyError

proc newRubyError*(msg: string): ref RubyError =
  var callstack = funcall(mKernel, intern("caller"), 0)
  var backtrace: seq[string] = @[]
  if callstack != qNil:
    assert getRbType(callstack) == tArray, "caller() did not return an array"

    for i in 0..<aryLength(callstack):
      var elem = aryEntry(callstack, i)
      assert getRbType(elem) == tString, "caller() array element was not string"
      var s = stringValueCstr(elem)
      backtrace.add $s

  result = newException(RubyError, fmt"{msg}")
  
  result.backtrace = backtrace


proc newRubyError*(err: RawValue): ref RubyError =
  var
    msgRaw = err.funcall(intern("message"), 0)
    backtraceRaw = err.funcall(intern("backtrace"), 0)
    typeName = objClassName(err)
    msg = stringValueCstr(msgRaw)

  var
    i = 0
    btEnt = qNil
    backtrace: seq[string] = @[]

  while true:
    btEnt = aryEntry(backtraceRaw, i)
    if btEnt == qNil:
      break
    
    var btEntStr = stringValueCstr(btEnt)
    backtrace.add($btEntStr)
    
    i += 1

  result = newException(RubyError, fmt"{msg} (Ruby: {typeName})")
  
  result.backtrace = backtrace


proc printBackTrace*(err: RubyError) =
  for bt in err.backtrace:
    echo "  ", bt

proc raiseRubyError*(message: string) =
  eRuntimeError.rbRaise(message.cstring)
