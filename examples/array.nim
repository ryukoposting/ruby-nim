import ruby

initRuby()

# equivalent to calling Array.new(1)
let arr = newRubyArray(1)

discard arr.push 3
discard arr.push "hello world!"

# .inspect() calls Ruby's 'inspect' method
echo arr.inspect()

# set an element of the ruby array
arr[0] = "foo!"

# inspect it again to see that the value changed
echo arr.inspect()

# get an element of the array, and inspect it
echo arr[1].inspect()

# iterate over elements of the array
for elem in arr.items():
  echo "- ", elem.inspect()

# make an array a member of itself???
arr[3] = arr

# ruby knows how to handle that. cool.
echo arr.inspect()

cleanupRuby()
