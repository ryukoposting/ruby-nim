import unittest
import ruby

initRuby()

test "basic arrays":
  let arr = newRubyArray()
  check arr[0].isNil()
  check arr.len() == 0
  arr[10] = "foo"
  check arr[10].getString() == "foo"
  check arr[0].isNil()
  check arr.len() == 11

test "arrays with initial size":
  let arr = newRubyArray(5)
  check arr.len() == 5
  check arr[0].isNil()
  check arr[1].isNil()
  check arr[2].isNil()
  check arr[3].isNil()
  check arr[4].isNil()

cleanupRuby()
