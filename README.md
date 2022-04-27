# ruby: Nim bindings for Matz's Ruby Interpreter (MRI)

The `ruby` Nim package provides access to the Ruby C API. The main goal of this project is to allow users to easily embed the Ruby interpreter inside of their Nim programs.

## Examples

```nim
# define a new module named Foo.
var myModule = newModule("Foo")

# {.rbModuleProc.} adds a class method to the module.
# you can call this method like this: Foo.say_hello("world")
proc say_hello(self: string): void {.rbModuleProc: myModule.} =
  echo "Hello ", self

# {.rbModuleMethod.} adds a normal method to the module.
# you can call this method on classes that include the module.
proc say_goodbye(self: RawValue): void {.rbModuleMethod: myModule.} =
  echo "Goodbye ", self.getInstanceVar("name").getString()
```

See the `examples` directory for more!

## Testing

This package has been validated with the following versions of `libruby`:

| Package Version  | `libruby` Version | Platform              | Status             |
|------------------|-------------------|-----------------------|--------------------|
| 0.1.0 and newer  | 2.7.0p0           | Ubuntu                | Tested, working    |
| 0.3.0 and newer  | 3.0.3p157         | Windows (MinGW-64)    | Tested, working    |

## Usage

On linux you will need to add this (or something very similar) to your `config.nims`:

```nim
switch("cincludes", "/usr/include/ruby-2.7.0")
switch("cincludes", "/usr/include/x86_64-linux-gnu/ruby-2.7.0")
switch("l", "-lruby-2.7")
```

On MinGW-64, you will need to add this (or something very similar) to your `config.nims`:

```nim
switch("cincludes", "c:/tools/msys64/mingw64/include/ruby-3.0.0")
switch("cincludes", "c:/tools/msys64/mingw64/include/ruby-3.0.0/x64-mingw32")
switch("passL", "C:/tools/msys64/mingw64/lib/libx64-msvcrt-ruby300.dll.a")
```

## More Information

- [The Definitive Guide to Ruby's C API](https://silverhammermba.github.io/emberb/c/)
