import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm, heapqueue, times]
import fusion/matching
import utils
import matrix



type
  Command = tuple
    dir: char
    len: int
    color: string
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
  FloodFiller = tuple
    prio: float
    x,y: int

proc solve*(input: string): int
proc digLavaLake*(input: string): int
proc floodFill(lake: var Matrix[char], xstart, ystart: int)

tests:
  solve(readFile("test.txt")) == 62
  solve(readFile("test2.txt")) == 74
  solve(readFile("input.txt")) == 56678



proc solve(input: string): int =
  input
    .digLavaLake()

proc digLavaLake(input: string): int =
  let commands = input
    .splitLines()
    .mapIt(it.split(" "))
    .mapIt((dir: it[0][0], len: it[1].parseInt, color: it[2]).Command)

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
        of 'U': U
        of 'R': R
        of 'D': D
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

  var lakeGrid = matrix(height, width, ' ')
  cx = xstart
  cy = ystart

  for wall in lake.walls:
    let
      dx = wall.aim.x * wall.len
      dy = wall.aim.y * wall.len
      ax = min(cx, cx + dx)
      ay = min(cy, cy + dy)
      bx = max(cx, cx + dx)
      by = max(cy, cy + dy)

    for y in ay..by:
      for x in ax..bx:
        lakeGrid[y, x] = '#'

    cx += dx
    cy += dy

  floodFill(lakeGrid, xstart, ystart)

  lakeGrid
    .data
    .filterIt(it == '#')
    .len

proc floodFill(lake: var Matrix[char], xstart, ystart: int) =
  var queue = [ (prio:0.0, x:xstart+1, y:ystart+1).FloodFiller ].toHeapQueue

  while queue.len > 0:
    let at = queue.pop()
    if lake[at.y, at.x] != ' ':
      continue

    lake[at.y, at.x] = '#'

    for dir in [1,3,5,7]:
      let
        x = dir mod 3
        y = dir div 3
        sx = at.x + (x - 1)
        sy = at.y + (y - 1)
        step = (
          prio: cpuTime(),
          x: sx,
          y: sy,
        ).FloodFiller

      if step.x < 0 or step.x > lake.lastCol or
         step.y < 0 or step.y > lake.lastRow:
        continue

      if lake[sy, sx] == ' ':
        queue.push(step)
