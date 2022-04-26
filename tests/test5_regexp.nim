import unittest
import ruby, ruby/lowlevel

initRuby()

test "convert regexp":
  let rawRe = eval("/.*/")
  let convRe = rawRe.getRegexp()
  check convRe.inspect() == "/.*/"

test "construct regexp":
  let myRe = newRubyRegexp(".*")
  check myRe.inspect() == "/.*/"



cleanupRuby()
