import ruby

# declare a new object type. The {.rbmark.} pragma
# tells the library that objects with this type should
# be analyzed by ruby's mark-and-sweep garbage collector.
type
  Tree {.rbmark.} = object
    left: RawValue
    right: RawValue
    value: int

initRuby()

# RTree helps set up the Ruby class
var RTree = wrapObjectType[Tree]("Tree")

RTree.useDefaultAllocator(Tree) # boilerplate. pls ignore

# define the "initialize" method for this class.
proc initialize(self: var Tree, value: int): void {.rbmethod: RTree.} =
  self.left = qNil   # qNil is Ruby's "nil"
  self.right = qNil
  self.value = value

# define some getter functions
proc left(self: var Tree): RawValue {.rbmethod: RTree.} = self.left
proc right(self: var Tree): RawValue {.rbmethod: RTree.} = self.right
proc value(self: var Tree): int {.rbmethod: RTree.} = self.value

# define some setter functions.
# notice how the {.rbmethod.} pragma is used differently here.
proc setLeft(self: var Tree, value: RawValue): RawValue {.rbmethod: (RTree, "left=").} =
  self.left = value
  return value

proc setRight(self: var Tree, value: RawValue): RawValue {.rbmethod: (RTree, "right=").} =
  self.right = value
  return value

proc setValue(self: var Tree, value: int): int {.rbmethod: (RTree, "value=").} =
  self.value = value
  return value

# now let's define a custom inspect() for our class.
# it will call the child nodes' inspect() recursively.
proc inspect(self: var Tree): string {.rbmethod: RTree.} =
  result = "(" & $self.value
  if not self.left.isNil():
    result &= " " & self.left.inspect()
  if not self.right.isNil():
    result &= " " & self.right.inspect()
  result &= ")"

# Some ruby code to show that the class works:

discard eval """

$x = Tree.new(1)
$x.left = Tree.new(2)
$x.right = Tree.new(3)
$x.left.right = Tree.new(4)

puts $x.inspect

"""

# we can inspect the tree by calling getGlobal:

let xValue = getGlobal("x").inspect()
assert xValue == "(1 (2 (4)) (3))"

# let's do the same thing again, but without the
# big, slow eval() block.

var yRaw = RTree.call("new", 1)

# xRaw is a RawValue - the id that Ruby uses to keep tabs
# on the object. That's not helpful to us, though, so let's
# unwrap it to get access to the Tree object inside.
var y = RTree.unsafeUnpack(yRaw)

# ^note that "unsafeUnpack" is only called "unsafe" because it
# doesn't do any type checking on the RawValue before converting
# it to a Tree. We know xRaw is a Tree, so it's 100% safe!

y.left = RTree.call("new", 2)
y.right = RTree.call("new", 3)

RTree.unsafeUnpack(y.left).right = RTree.call("new", 4)

let yValue = yRaw.inspect()
assert yValue == xValue


cleanupRuby()
