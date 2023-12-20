import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm, heapqueue, times]
import fusion/matching
import utils
import matrix



type
  Command = tuple
    dir: char
    len: int
  Vector2 = tuple
    x,y: int
  Direction = enum
    U, R, D, L

proc solve*(input: string): int
proc digLavaLake*(input: string): int
proc shoelace*(vertices: seq[Vector2]): int

tests:
  solve(readFile("test.txt")) == 952408144115
  solve(readFile("input.txt")) == 79088855654037



proc solve(input: string): int =
  input
    .digLavaLake()

proc digLavaLake(input: string): int =
  let commands = input
    .splitLines()
    .mapIt(it.split(" "))
    .mapIt((dir: it[2][7], len: it[2][2..<7]))
    .mapIt((dir: it.dir, len: fromHex[int](it.len)).Command)

  var
    vertices = newSeq[Vector2]()
    perimeter = 0
    cx = 0
    cy = 0

  for command in commands:
    let
      pos = (cx, cy).Vector2
      dir = case command.dir
        of '3': U
        of '0': R
        of '1': D
        else: L
      len = command.len

    vertices.add(pos)
    perimeter += len

    case dir:
    of U: cy -= len
    of R: cx += len
    of D: cy += len
    of L: cx -= len

  shoelace(vertices) +
    perimeter div 2 +
    1 # we started digging from a 1x1 hole

proc shoelace*(vertices: seq[Vector2]): int =
  var area = 0

  for v in 0 ..< vertices.len-1:
    let
      (x1, y1) = vertices[v]
      (x2, y2) = vertices[v + 1]

    area += x1 * y2 - x2 * y1

  area div 2
