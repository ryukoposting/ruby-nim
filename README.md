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

Once you have installed the package, you can run `nimble example <name>` to run one of the examples. Run `nimble example` to get a list of available examples.

## Testing

This package has been validated with the following versions of `libruby`:

| Package Version  | `libruby` Version | Platform              | Status          |
|------------------|-------------------|-----------------------|-----------------|
| 0.1.0 and newer  | 2.7.0p0           | Ubuntu                | Unit tests pass |
| 0.3.0 and newer  | 3.0.3p157         | Windows (MinGW-64)    | Unit tests pass |

Versions of this package before `0.3.1` have stability problems on MinGW, particularly in situations where Ruby is trying to perform file and/or terminal IO. `0.3.1` should address this issue.

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

## Configuration

`ruby` allows you to configure the package with a handful of `-d:` flags:

### `rubyLibName`

Change the pattern used to find the `libruby` DLL.

**Example**: `--define:rubyLibName=libruby-3.2.so`

**Defaults**:

| Platform            | Default Value                                            |
|---------------------|----------------------------------------------------------|
| Windows             | `"x64-(msvcrt|ucrt)-ruby(|240|250|260|270|300|310).dll"` |
| Mac                 | `"libruby(|-2.4|-2.5|-2.6|-2.7|-3.0|-3.1).dylib"`        |
| All other platforms | `"libruby(|-2.4|-2.5|-2.6|-2.7|-3.0|-3.1).so"`           |


### `noRubyPrimitiveConversions`

By default, the `ruby` package provides templates that allow for implicit conversion of basic Nim datatypes (`int`, `float`, `string`, and `bool`) to `RubyValue`s.

When `noRubyPrimitiveConversions` is defined, this feature is disabled, and you must explicitly call the `toRawInt`, `toRawFloat`, `toRawStr`, and `toRawBool` procs to convert basic Nim datatypes to `RubyValue`.

**Example**:

```nim
let arr = newRubyArray()

when not defined(noRubyPrimitiveConversions):
  arr[0] = 100
else:
  arr[0.toRawInt()] = 100.toRawInt()
```


## More Information

- [The Definitive Guide to Ruby's C API](https://silverhammermba.github.io/emberb/c/)
