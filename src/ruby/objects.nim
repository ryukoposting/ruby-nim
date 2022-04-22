import ../ruby/[lowlevel, types, misc]
import ../ruby/private/[utils]

proc getObject*(rv: RawValue): RubyObject =
  requireType(rv, tObject, "Object")
  result.rawVal = rv

proc extend*(self: RubyObject, module: RubyModule) =
  self.rawVal.extendObject(module.rawVal)
