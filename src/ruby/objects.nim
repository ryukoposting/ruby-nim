
# 
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# 

import ../ruby/[lowlevel, types, misc]
import ../ruby/private/[utils]

proc getObject*(rv: RawValue): RubyObject =
  requireType(rv, tObject, "Object")
  result.rawVal = rv

proc extend*(self: RubyObject, module: RubyModule) =
  self.rawVal.extendObject(module.rawVal)
