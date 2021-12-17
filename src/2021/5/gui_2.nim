import std/[strformat, strutils, sequtils, sugar, json]
import data
import elvis
import tools
import utils



iterator pairs(line: Line): Point =
  var
    x = line.x1
    y = line.y1
  let
    xmax = line.x2
    ymax = line.y2

    dx = if x < xmax:
           1
         elif x > xmax:
           -1
         else:
           0
    dy = if y < ymax:
           1
         elif y > ymax:
           -1
         else:
           0

  yield (x:x, y:y)
  while x != xmax or y != ymax:
    x += dx
    y += dy
    yield (x:x, y:y)



const
  GUI_POINT_SIZE = 40
  GUI_POINT_MARGIN = 5
  GUI_LINE_COLORS = @["#7b7", "#b77", "#77b", "#7bb", "#b7b", "#bb7", "#b70", "#7b0", "#07b", "#0b7"]



proc solve*(input: string): int =
  let (lines, cols, rows) = parseData(input)
  var seabed              = newSeqWith(rows+1, newSeq[int](cols+1))

  animationFrequency = 50
  guiAddElement(proc (): JsonNode =
    %* {
      "id": "answer",
      "tag": "p",
      "position": {
        "x": 10,
        "y": (GUI_POINT_SIZE + GUI_POINT_MARGIN) * (rows + 1),
      }
    }
  )

  for y in 0 .. rows:
    for x in 0 .. cols:
      guiAddElement(proc (): JsonNode =
        %* {
          "id": fmt"seabed-{y}-{x}",
          "tag": "div",
          "bg": "#ddd",
          "size": {
            "width":  GUI_POINT_SIZE,
            "height": GUI_POINT_SIZE,
          },
          "position": {
            "x": (GUI_POINT_SIZE + GUI_POINT_MARGIN) * x,
            "y": (GUI_POINT_SIZE + GUI_POINT_MARGIN) * y,
          }
        }
      )

  for index, line in lines:
    for x, y in line:
      guiAddElement(proc (): JsonNode =
        %* {
          "id": fmt"line-{index}-{y}-{x}",
          "tag": "div",
          "size": {
            "width":  GUI_POINT_SIZE,
            "height": GUI_POINT_SIZE,
          },
          "position": {
            "x": (GUI_POINT_SIZE + GUI_POINT_MARGIN) * x,
            "y": (GUI_POINT_SIZE + GUI_POINT_MARGIN) * y,
          }
        }
      )

  for index, line in lines:
    for x, y in line:
      seabed[y][x] += 1

      if seabed[y][x] > 1:
        guiUpdateElement(proc (): JsonNode =
          %* {
            "id": fmt"seabed-{y}-{x}",
            "bg": "#000",
            "size": {
              "width":  GUI_POINT_SIZE + GUI_POINT_MARGIN * 2,
              "height": GUI_POINT_SIZE + GUI_POINT_MARGIN * 2,
            },
            "position": {
              "x": (GUI_POINT_SIZE + GUI_POINT_MARGIN) * x - GUI_POINT_MARGIN,
              "y": (GUI_POINT_SIZE + GUI_POINT_MARGIN) * y - GUI_POINT_MARGIN,
            }
          }
        )
      guiUpdateElement(proc (): JsonNode =
        %* {
          "id": fmt"line-{index}-{y}-{x}",
          "bg": GUI_LINE_COLORS[index],
        }
      )

  # sum all points on seabed where the value is greater than 1
  let answer = seabed.foldl(a + b.foldl(a + (b > 1 ? 1 ! 0), 0), 0)

  guiUpdateElement(proc (): JsonNode =
    %* {
      "id": "answer",
      "text": fmt"Final answer = {answer}"
    }
  )

  answer
