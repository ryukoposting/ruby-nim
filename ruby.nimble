# Package

version       = "0.4.0"
author        = "Evan Perry Grove"
description   = "Ruby Interpreter API Bindings"
license       = "MPL-2.0"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.0"

from os import walkDir, splitFile, `/`, ExeExt
from strutils import allCharsInSet

var chosenExamples: seq[string]

task example, "Run examples":
  for param in commandLineParams:
    if param.allCharsInSet {'a'..'z', '_', '0'..'9'}:
      chosenExamples.add param

  if chosenExamples.len() == 0:
    echo "No examples were given! The following examples are available:"
    for (_, exampleFile) in walkDir("examples"):
      let (_, name, _) = exampleFile.splitFile()
      echo " - ", name
    echo "** Please specify one or more examples to run. **"
    quit(1)
  else:
    echo chosenExamples.len(), " example(s) were selected."


  for name in chosenExamples:
    let
      examplePath = "."/"examples"/name & ".nim"
      exampleExe = "."/"examples"/name & ExeExt

    if fileExists examplePath:
      echo "Running example `", name, "'"
      exec "nim c -r " & examplePath
    else:
      echo "** Example `", name, "' (", examplePath, ") does not exist. **"
      quit(1)
