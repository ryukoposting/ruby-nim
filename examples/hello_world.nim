import ruby

initRuby()

discard eval(""" puts "hello, world!" """)

let num = eval("1 + 1").getInt()
assert num == 2

cleanupRuby()
