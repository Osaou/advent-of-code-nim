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
proc shineLight*(input: string, xStart,yStart: int, direction: Direction): Matrix[Tile]
proc energyLevels*(contraption: Matrix[Tile]): int
proc shine*(contraption: var Matrix[Tile], xStart,yStart: int, direction: Direction)
proc light*(tile: Tile): seq[Direction]

tests:
  solve(readFile("test.txt")) == 51
  solve(readFile("input.txt")) == 8183



proc solve(input: string): int =
  let gridSize = input.find("\n") - 1
  var record = 0

  for y in 0 ..< gridSize:
    let e1 = shineLight(input, 0, y, Right).energyLevels
    if e1 > record:
      record = e1

    let e2 = shineLight(input, gridSize, y, Left).energyLevels
    if e2 > record:
      record = e2

  for x in 0 ..< gridSize:
    let e1 = shineLight(input, x, 0, Down).energyLevels
    if e1 > record:
      record = e1

    let e2 = shineLight(input, x, gridSize, Up).energyLevels
    if e2 > record:
      record = e2

  record

proc shineLight(input: string, xStart,yStart: int, direction: Direction): Matrix[Tile] =
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

  shine(contraption, xStart,yStart, direction)
  contraption

proc energyLevels(contraption: Matrix[Tile]): int =
  contraption
    .data
    .foldl(a + (if light(b).len > 0: 1 else: 0), 0)

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
