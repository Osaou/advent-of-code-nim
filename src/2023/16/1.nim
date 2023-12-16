import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils
import matrix



type
  Direction = enum
    Up, Right, Down, Left

  Tile = ref object
    mirror: char
    light: TableRef[Direction, bool]

proc solve*(input: string): int
proc shineLight*(input: string): Matrix[Tile]
proc shine*(contraption: var Matrix[Tile], xStart,yStart: int, direction: Direction)
proc light*(tile: Tile): seq[Direction]
proc debugLight*(contraption: Matrix[Tile]): string
proc debugEnergyLevels*(contraption: Matrix[Tile]): string

tests:
  solve(readFile("test.txt")) == 46
  solve(readFile("input.txt")) == 7434



proc solve(input: string): int =
  let contraption = shineLight(input)
  #[
  echo "light:"
  echo debugLight(contraption)

  echo "energy levels:"
  echo debugEnergyLevels(contraption)
  #]#

  contraption
    .data
    .foldl(a + (if light(b).len > 0: 1 else: 0), 0)

proc shineLight(input: string): Matrix[Tile] =
  let mirrors = input
    .split("\n")
    .mapIt(it.toSeq)
    .matrix

  var contraption = matrix[Tile](mirrors.rows, mirrors.cols)
  for y in 0 ..< contraption.rows:
    for x in 0 ..< contraption.cols:
      contraption[y,x] = Tile(
        mirror: mirrors[y,x],
        light: {
          Up: false,
          Right: false,
          Down: false,
          Left: false,
        }.newTable
      )

  shine(contraption, 0,0, Right)
  contraption

proc shine(contraption: var Matrix[Tile], xStart,yStart: int, direction: Direction) =
  var
    x = xStart
    y = yStart
    dir = direction

  while true:
    # stop if we have moved past the border of the grid
    if x < 0 or x > contraption.lastCol or
       y < 0 or y > contraption.lastRow:
      return

    # stop if we have already shone light on this tile in this direction
    if contraption[y,x].light[dir]:
      return

    # energize tile
    contraption[y,x].light[dir] = true

    # move light beam
    case contraption[y,x].mirror:
    of '|':
      case dir:
      of Left, Right:
        shine(contraption, x, y-1, Up)
        shine(contraption, x, y+1, Down)
        return
      of Up, Down:
        discard
    of '-':
      case dir:
      of Left, Right:
        discard
      of Up, Down:
        shine(contraption, x-1, y, Left)
        shine(contraption, x+1, y, Right)
        return
    of '/':
      case dir:
      of Up:
        dir = Right
      of Right:
        dir = Up
      of Down:
        dir = Left
      of Left:
        dir = Down
    of '\\':
      case dir:
      of Up:
        dir = Left
      of Right:
        dir = Down
      of Down:
        dir = Right
      of Left:
        dir = Up
    else:
      discard

    # follow updated direction to next tile
    case dir:
    of Up: y -= 1
    of Right: x += 1
    of Down: y += 1
    of Left: x -= 1

proc light(tile: Tile): seq[Direction] =
  collect:
    for direction, hasLight in tile.light.pairs:
      if hasLight:
        direction

#[ tests:
  debugLight(shineLight(readFile("test.txt"))) == """>|<<<\....
|v-.\^....
.v...|->>>
.v...v^.|.
.v...v^...
.v...v^..\
.v../2\\..
<->-/vv|..
.|<<<2-|.\
.v//.|.v..
"""
]#
proc debugLight(contraption: Matrix[Tile]): string =
  for y in 0 ..< contraption.rows:
    for x in 0 ..< contraption.cols:
      let tile = contraption[y,x].mirror
      if tile == '.':
        let light = light(contraption[y,x])
        case light.len
        of 0:
          result = result & "."
        of 1:
          case light[0]
          of Up: result = result & "^"
          of Right: result = result & ">"
          of Down: result = result & "v"
          of Left: result = result & "<"
        else:
          result = result & $light.len
      else:
        result = result & tile
    result = result & "\n"

#[ tests:
  debugEnergyLevels(shineLight(readFile("test.txt"))) == """OOOOOO....
.O...O....
.O...OOOOO
.O...OO...
.O...OO...
.O...OO...
.O..OOOO..
OOOOOOOO..
.OOOOOOO..
.O...O.O..
"""
]#
proc debugEnergyLevels(contraption: Matrix[Tile]): string =
  for y in 0 ..< contraption.rows:
    for x in 0 ..< contraption.cols:
      let light = light(contraption[y,x])
      if light.len > 0:
        result = result & "O"
      else:
        result = result & "."
    result = result & "\n"
