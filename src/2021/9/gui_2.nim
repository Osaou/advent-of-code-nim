import std/[strformat, strutils, sequtils, sugar, algorithm, json, tables, math]
import fusion/matching
#import utils
import tools
import data



const
  GUI_CAVE_SIZE = 40
  GUI_CAVE_MARGIN = 5
  GUI_CAVE_COLORS = @["#00a", "#22b", "#44b", "#66c", "#88d", "#aae", "#bbe", "#ccf", "#ddf", "#777"]
  GUI_TOP_CAVE_COLORS = @["#a00", "#b22", "#b44", "#c66", "#d88", "#eaa", "#ebb", "#fcc", "#fdd", "#777"]



type
  Coord = tuple
    x,y: int

  Basin = tuple
    size: int
    id: int

  BasinMarker = object
    map: Heightmap
    markedCoords: seq[bool]
    basins: seq[Basin]
    basinContent: Table[int, seq[Coord]]

func newBasinMarker(map: Heightmap): BasinMarker =
  BasinMarker(
    map: map,
    markedCoords: newSeqWith(map.xlen * map.ylen, false)
  )

func isMarked(marked: BasinMarker, x,y: int): bool =
  marked.markedCoords[y * marked.map.xlen + x]

proc markBasin(marked: var BasinMarker, x,y: int, id: int): int =
  # check if we're out of bounds
  if marked.isMarked(x, y) or marked.map.heightValue(x, y) == 9:
    return 0

  # mark this position
  marked.markedCoords[y * marked.map.xlen + x] = true
  marked.basinContent
    .mgetOrPut(id, @[])
    .add((x:x, y:y))

  # iterate over all neighbors, and mark them too, if appropriate
  # return sum of marked neighbors, plus 1 for current coordinate
  marked.map
    .neighborCoords(x, y)
    .mapIt(marked.markBasin(it[0], it[1], id))
    .sum() + 1

func addBasin(marked: var BasinMarker, size: int, id: int) =
  marked.basins &= (size:size, id:id)



proc solve*(input: string): int =
  let
    map = newHeightmap(input)
  var
    marked = newBasinMarker(map)

  for y in 0 .. map.ymax:
    for x in 0 .. map.xmax:
      let value = map.heightValue(x, y)
      guiAddElement(proc (): JsonNode =
        %* {
          "id": fmt"cave-{y}-{x}",
          "tag": "div",
          "text": fmt"{value}",
          "bg": GUI_CAVE_COLORS[value],
          "size": {
            "width":  GUI_CAVE_SIZE,
            "height": GUI_CAVE_SIZE,
          },
          "position": {
            "x": (GUI_CAVE_SIZE + GUI_CAVE_MARGIN) * x,
            "y": (GUI_CAVE_SIZE + GUI_CAVE_MARGIN) * y,
          }
        }
      )
      let
        id = y * map.xlen + x
        basinSize = marked.markBasin(x, y, id)
      if basinSize > 0:
        marked.addBasin(basinSize, id)

  # multiply 3 largest basins
  [@first, @second, @third, all _] := marked.basins.sorted((a,b) => cmp(a.size, b.size)).reversed()

  for top in @[first, second, third]:
    for (x, y) in marked.basinContent[top.id]:
      let value = map.heightValue(x, y)
      guiUpdateElement(proc (): JsonNode =
        %* {
          "id": fmt"cave-{y}-{x}",
          "bg": GUI_TOP_CAVE_COLORS[value]
        }
      )

  first.size * second.size * third.size
