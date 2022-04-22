import ruby

initRuby()

var myModule = newModule("Foo")

# {.rbModuleProc.} adds a class method to the module.
proc say_hello(self: string): void {.rbModuleProc: myModule.} =
  echo "Hello ", self

# {.rbModuleMethod.} adds a normal method to the module.
proc say_goodbye(self: RawValue): void {.rbModuleMethod: myModule.} =
  echo "Goodbye ", self.getInstanceVar("name").getString()

discard eval """

Foo.say_hello "world!"

class Bar
  include Foo
  def initialize
    @name = "cruel world!"
  end
end

bar = Bar.new

bar.say_goodbye

"""

cleanupRuby()
