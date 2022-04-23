import unittest
import ruby

initRuby()

test "basic hash creation":
  let hash = newRubyHash()
  check hash[1].isNil()
  check hash[2].isNil()
  check hash[3].isNil()
  hash["foo"] = "bar"
  check hash["foo"].getString() == "bar"

test "hash with default value":
  var hash = newRubyHash("foo!")
  check hash[1].getString() == "foo!"
  hash[1.rawVal()] = "bar!".rawVal()
  check hash[1].getString() == "bar!"

test "hash iteration":
  var hash = newRubyHash()
  hash[1] = 2
  hash[3] = 4
  hash[4] = 5
  hash[6] = 8
  for key in hash.keys():
    check key.isInt()
    let k = key.getInt()
    let value = getInt hash[key]
    if k == 1:
      check value == 2
    elif k == 3:
      check value == 4
    elif k == 4:
      check value == 5
    elif k == 6:
      check value == 8

cleanupRuby()
