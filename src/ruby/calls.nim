import ../ruby/[lowlevel, types, misc]
import ../ruby/private/[utils]

proc call*(self: RubyValue, methodName: string, nargs: int, args: ptr RawValue): RawValue =
  self.rawVal.funcallv(
    intern(methodName), nargs.cint,
    args
  )

template rawVal*(x: int): RawValue = x.toRawInt()
template rawVal*(x: float): RawValue = x.toRawFloat()
template rawVal*(x: string): RawValue = x.toRawStr()
template rawVal*(x: bool): RawValue = x.toRawBool()


template call*(self: RubyValue, methodName: string): RawValue =

  self.call(methodName, 0, cast[ptr RawValue](nil))

template call*(self: RubyValue, methodName: string, arg0: RubyValue | string | int | float | bool): RawValue =
  var argv = [arg0.rawVal]
  self.call(methodName, 1, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal]
  self.call(methodName, 2, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal]
  self.call(methodName, 3, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal]
  self.call(methodName, 4, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal]
  self.call(methodName, 5, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4, arg5: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal, arg5.rawVal]
  self.call(methodName, 6, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4, arg5, arg6: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal, arg5.rawVal, arg6.rawVal]
  self.call(methodName, 7, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal, arg5.rawVal, arg6.rawVal, arg7.rawVal]
  self.call(methodName, 8, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal, arg5.rawVal, arg6.rawVal, arg7.rawVal, arg8.rawVal]
  self.call(methodName, 9, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal, arg5.rawVal, arg6.rawVal, arg7.rawVal, arg8.rawVal, arg9.rawVal]
  self.call(methodName, 10, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal, arg5.rawVal, arg6.rawVal, arg7.rawVal, arg8.rawVal, arg9.rawVal, arg10.rawVal]
  self.call(methodName, 11, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal, arg5.rawVal, arg6.rawVal, arg7.rawVal, arg8.rawVal, arg9.rawVal, arg10.rawVal, arg11.rawVal]
  self.call(methodName, 12, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal, arg5.rawVal, arg6.rawVal, arg7.rawVal, arg8.rawVal, arg9.rawVal, arg10.rawVal, arg11.rawVal, arg12.rawVal]
  self.call(methodName, 13, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal, arg5.rawVal, arg6.rawVal, arg7.rawVal, arg8.rawVal, arg9.rawVal, arg10.rawVal, arg11.rawVal, arg12.rawVal, arg13.rawVal]
  self.call(methodName, 14, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal, arg5.rawVal, arg6.rawVal, arg7.rawVal, arg8.rawVal, arg9.rawVal, arg10.rawVal, arg11.rawVal, arg12.rawVal, arg13.rawVal, arg14.rawVal]
  self.call(methodName, 15, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal, arg5.rawVal, arg6.rawVal, arg7.rawVal, arg8.rawVal, arg9.rawVal, arg10.rawVal, arg11.rawVal, arg12.rawVal, arg13.rawVal, arg14.rawVal, arg15.rawVal]
  self.call(methodName, 16, cast[ptr RawValue](addr argv))

template call*(self: RubyValue, methodName: string, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16: RubyValue | string | int | float | bool): RawValue =

  var argv = [arg0.rawVal, arg1.rawVal, arg2.rawVal, arg3.rawVal, arg4.rawVal, arg5.rawVal, arg6.rawVal, arg7.rawVal, arg8.rawVal, arg9.rawVal, arg10.rawVal, arg11.rawVal, arg12.rawVal, arg13.rawVal, arg14.rawVal, arg15.rawVal, arg16.rawVal]
  self.call(methodName, 17, cast[ptr RawValue](addr argv))
