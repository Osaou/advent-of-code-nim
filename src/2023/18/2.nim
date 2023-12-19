import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm, heapqueue, times]
import fusion/matching
import utils
import matrix



type
  Command = tuple
    dir: char
    len: int
  Vector2 = object
    x,y: int
  Direction = enum
    U, R, D, L
  Wall = object
    pos: Vector2
    aim: Vector2
    dir: Direction
    len: int
  Lake = object
    walls: seq[Wall]

proc solve*(input: string): int
proc digLavaLake*(input: string): int

tests:
  solve(readFile("test.txt")) == 62952408144115
#  solve(readFile("input.txt")) ==



proc solve(input: string): int =
  input
    .digLavaLake()

proc digLavaLake(input: string): int =
  let commands = input
    .splitLines()
    .mapIt(it.split(" "))
    .mapIt((dir: it[2][7], len: it[2][2..<7]))
    .mapIt((dir: it.dir, len: fromHex[int](it.len)).Command)

  echo commands[0]

  var
    lake = Lake(walls: newSeq[Wall]())
    cx = 0
    cy = 0
    xmin = 0
    xmax = 0
    ymin = 0
    ymax = 0

  for command in commands:
    let
      pos = Vector2(x:cx, y:cy)
      dir = case command.dir
        of '3': U
        of '0': R
        of '1': D
        else: L
      trajectory = case dir
        of U: Vector2(x: 0, y: -1)
        of R: Vector2(x: 1, y: 0)
        of D: Vector2(x: 0, y: 1)
        of L: Vector2(x: -1, y: 0)
      len = command.len
      wall = Wall(pos:pos, aim:trajectory, dir:dir, len:len)

    lake.walls.add(wall)

    case dir:
    of U: cy -= len
    of R: cx += len
    of D: cy += len
    of L: cx -= len

    if cx < xmin:
      xmin = cx
    if cx > xmax:
      xmax = cx

    if cy < ymin:
      ymin = cy
    if cy > ymax:
      ymax = cy

  let
    width = xmax + abs(xmin) + 1
    height = ymax + abs(ymin) + 1
    xstart = abs(xmin)
    ystart = abs(ymin)

  echo "width: ", width
  echo "height: ", height
