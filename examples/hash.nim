import ruby

initRuby()

# create a new hash. Its default value is 1234.
# this is effectively the same as calling Hash.new(1234)
let h1 = newRubyHash(1234)

# add a new value to the hash.
h1["foo"] = "bar"
echo "h1.inspect(): ", h1.inspect()
assert h1["foo"].getString() == "bar"

# add another value to the hash, but use a Ruby symbol
# instead of a string.
h1[sym"foo"] = "baz".rawVal
echo "h1.inspect(): ", h1.inspect()
assert h1[sym"foo"].getString() == "baz"

# iterate over keys in the hash
for k in h1.keys():
  echo "key=", k.inspect(), " value=", h1[k].inspect()

# delete a key from the hash
let oldValue = h1.delete(sym"foo")
assert oldValue.isString()
assert oldValue.getString() == "baz"

# try to read from a key that isn't in the hash
let defaultValue = h1["notInTheHash"]
assert defaultValue.isInt()
assert defaultValue.getInt() == 1234

cleanupRuby()
