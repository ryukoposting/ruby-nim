import unittest
import ruby

initRuby()

test "basic sym construction":
  let foo = sym"foo"
  check foo.inspect() == "foo"

test "can get ints":
  check eval("1 + 1").getInt() == 2

test "can convert ints":
  setGlobal("value", 2.toRawInt())
  check getGlobal("value").getInt() == 2

test "can get floats":
  check eval("3.5 + 4").getFloat() == 7.5

test "can convert floats":
  setGlobal("value", 3.14.toRawFloat())
  check getGlobal("value").getFloat() == 3.14

test "can get strings":
  check eval("\"Hello world\"").getString() == "Hello world"

test "can convert strings":
  setGlobal("value", "Hello world".toRawStr())
  check getGlobal("value").getString() == "Hello world"

test "can get symbols":
  check eval(":helloworld").getSymbol() == "helloworld"

test "can convert symbols":
  setGlobal("value", "helloworld".toRawSym())
  check getGlobal("value").getSymbol() == "helloworld"

cleanupRuby()
