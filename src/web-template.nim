import std/strformat
import std/sugar
import std/deques
import std/json
import dom
import utils
import tools
import logic



proc processUiUpdates() =
  if updates.len <= 0:
    echo "empty stack"
    return

  let
    json = updates.popFirst
    id = json["id"].getStr |> cstring
    element = document.getElementById(id)

  # set image source?
  processSingleUiUpdate(element, json)

  # log to console and schedule next update with slight delay
  echo json |> pretty |> cstring
  discard setTimeout(processUiUpdates, 5)



proc main(jsInput: cstring): int {.exportc.} =
  let
    input = $(jsInput)
    answer = logic(input)

  processUiUpdates()
  echo answer
