# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import std/json
import tools



# tests
const
  expectedTestResult* = 900
  expectedRunResult* = 1954293920



# logic
proc logic*(input: string): int =
  animationFrequency = 5
  guiAddElement(proc (): JsonNode =
    %* {
      "id": "submarine",
      "tag": "img",
      "image": guiResource("submarine.jfif"),
      "size": {
        "width":  int(436 * 0.1),
        "height": int(291 * 0.1)
      }
    }
  )
  guiAddElement(proc (): JsonNode =
    %* {
      "id": "answer",
      "tag": "p"
    }
  )

  let trajectory = input
    .splitLines
    .filterIt(it.strip() != "")
    .map(str => str.split(" "))
    .map(arr => (dir: arr[0], speed: parseInt(arr[1])))
  var
    aim = 0
    depth = 0
    position = 0

  for move in trajectory:
    case move.dir
      of "up":
        aim -= move.speed
      of "down":
        aim += move.speed
      of "forward":
        position += move.speed
        depth += aim * move.speed

    guiUpdateElement(proc (): JsonNode =
      %* {
        "id": "submarine",
        "rotation": int(aim / 1000 * 45),
        "position": {
          "x": int(position / 2),
          "y": int(depth / 1500)
        }
      }
    )
    guiUpdateElement(proc (): JsonNode =
      %* {
        "id": "answer",
        "text": fmt"Interim answer = {position * depth}"
      }
    )

    #echo fmt"Position: {position}, Depth: {depth}, Aim: {aim}"

  guiUpdateElement(proc (): JsonNode =
    %* {
      "id": "answer",
      "text": fmt"Final answer = {position * depth}"
    }
  )
  position * depth
