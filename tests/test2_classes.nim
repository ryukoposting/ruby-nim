import std/unittest
import ruby

type
  MyObject {.rbmark.} = object
    x: int

initRuby()


var RMyObject = wrapObjectType[MyObject]("MyObject")
RMyObject.useDefaultAllocator(MyObject)

proc initialize(self: var MyObject, a: int, b: int): void {.rbmethod: RMyObject.} =
  self.x = a + b

proc x(self: var MyObject): int {.rbmethod: RMyObject.} =
  self.x

proc set_x(self: var MyObject, value: int): void {.rbMethod: (RMyObject, "x=").} =
  self.x = value


test "class was created":
  check eval("MyObject").isClass()

test "create instance":
  setGlobal "value", eval("MyObject").call("new", 3, 5)
  let value = getGlobal "value"
  check value.call("x").getInt() == 8
  check value.className() == "MyObject"
  check value.class().inspect() == "MyObject"

test "explicit method name":
  let value = getGlobal "value"
  discard value.call("x=", 1000)
  check value.call("x").getInt() == 1000

cleanupRuby()
