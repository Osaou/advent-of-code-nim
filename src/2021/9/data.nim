import std/strutils
import std/sequtils
import std/sugar
import fusion/matching
import math
import utils

{.experimental: "caseStmtMacros".}



type
  Heightmap* = object
    xlen*, ylen*: int
    xmax*, ymax*: int
    heightValues: seq[int]



func charToInt(c: char): int =
  c.int - 48

func newHeightmap*(input: string): Heightmap =
  let
    values = input
      .splitLines()
      .mapIt(toSeq it)
      .mapIt(it.map(charToInt))

    xlen = values[0].len
    ylen = values.len
    xmax = xlen - 1
    ymax = ylen - 1

    heightmap = collect(newSeq):
      for row in values:
        for height in row:
          height

  Heightmap(
    xlen:xlen, ylen:ylen,
    xmax:xmax, ymax:ymax,
    heightValues: heightmap
  )



func heightValue*(hm: Heightmap, x,y: int): int =
  hm.heightValues[y * hm.xlen + x]

func heightValueFromSeq*(hm: Heightmap, pos: seq[int]): int =
  hm.heightValue(pos[0], pos[1])

func neighborCoords*(hm: Heightmap, x,y: int): seq[seq[int]] =
  let
    xmax = hm.xmax
    ymax = hm.ymax
  case @[x, y]:
    of [0, 0]:        @[@[0, 1], @[1, 0]]
    of [0, ymax]:     @[@[0, y-1], @[x+1, 0]]
    of [xmax, 0]:     @[@[x-1, 0], @[0, y+1]]
    of [0, _]:        @[@[0, y-1], @[0, y+1], @[x+1, y]]
    of [_, 0]:        @[@[x-1, 0], @[x+1, 0], @[x, y+1]]
    of [xmax, ymax]:  @[@[x, y-1], @[x-1, y]]
    of [xmax, _]:     @[@[xmax, y-1], @[xmax, y+1], @[x-1, y]]
    of [_, ymax]:     @[@[x-1, ymax], @[x+1, ymax], @[x, y-1]]
    else:             @[@[x-1, y], @[x+1, y], @[x, y-1], @[x, y+1]]
