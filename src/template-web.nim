import std/strformat
import std/sugar
import std/deques
import std/json
import dom
import utils
import tools
import solution



proc processUiUpdates() =
  if updates.len <= 0:
    return

  let
    json = updates.popFirst
    id = json["id"].getStr |> cstring
    element = document.getElementById(id)

  # set image source?
  processSingleUiUpdate(element, json)

  # schedule next update with slight delay
  discard setTimeout(processUiUpdates, animationFrequency)



proc run(jsInput: cstring): int {.exportc.} =
  let
    input = $(jsInput)
    answer = solve(input)

  processUiUpdates()
  echo fmt"Final answer: {answer}"
