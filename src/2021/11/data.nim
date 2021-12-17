import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import fusion/matching



const
  octopiGroupEdgeCount = 10
  octopiGroupEdgeMaxIndex = octopiGroupEdgeCount - 1

func isInt(c: char): bool =
  c.int >= 48 and
  c.int <= 57

func charToInt(c: char): int =
  c.int - 48

type
  OctopusGroup* = object
    octopi*: seq[int]
    flashCount*: int64

func newOctopusGroup*(input: string): OctopusGroup =
  let octopi = collect(newSeq):
    for nr in input:
      if isInt(nr):
        charToInt(nr)

  OctopusGroup(octopi:octopi, flashCount:0)

func getLuminescence(group: OctopusGroup, x,y: int): int =
  group.octopi[y * octopiGroupEdgeCount + x]

proc setLuminescence(group: var OctopusGroup, x,y, value: int) =
  group.octopi[y * octopiGroupEdgeCount + x] = value

proc increaseLuminescence(group: var OctopusGroup, x,y: int): int =
  let value = group.octopi[y * octopiGroupEdgeCount + x] + 1
  group.octopi[y * octopiGroupEdgeCount + x] = value
  value

func neighborCoords(x,y: int): seq[seq[int]] =
  let
    xmax = octopiGroupEdgeMaxIndex
    ymax = octopiGroupEdgeMaxIndex
  case @[x, y]:
    of [0, 0]:        @[@[0, 1], @[1, 0], @[1, 1]]                                                                        # top-left
    of [0, ymax]:     @[@[0, y-1], @[x+1, y], @[x+1, y-1]]                                                                # bottom-left
    of [xmax, 0]:     @[@[x-1, 0], @[xmax, y+1], @[x-1, y+1]]                                                             # top-right
    of [xmax, ymax]:  @[@[x, y-1], @[x-1, y], @[x-1, y-1]]                                                                # bottom-right
    of [0, _]:        @[@[0, y-1], @[0, y+1], @[x+1, y], @[x+1, y-1], @[x+1, y+1]]                                        # left edge
    of [_, 0]:        @[@[x-1, 0], @[x+1, 0], @[x, y+1], @[x-1, y+1], @[x+1, y+1]]                                        # top edge
    of [xmax, _]:     @[@[xmax, y-1], @[xmax, y+1], @[x-1, y], @[x-1, y-1], @[x-1, y+1]]                                  # right edge
    of [_, ymax]:     @[@[x-1, ymax], @[x+1, ymax], @[x, y-1], @[x-1, y-1], @[x+1, y-1]]                                  # bottom edge
    else:             @[@[x-1, y-1], @[x, y-1], @[x+1, y-1], @[x-1, y], @[x+1, y], @[x-1, y+1], @[x, y+1], @[x+1, y+1]]   # anywhere else

proc propagateEnergy(group: var OctopusGroup, x,y: int) =
  let energy = group.increaseLuminescence(x, y)

  if energy > 9:
    group.setLuminescence(x, y, low(int))
    group.flashCount += 1

    for neighbor in neighborCoords(x, y):
      [@x, @y] := neighbor
      group.propagateEnergy(x, y)

proc modelSingleStep*(group: var OctopusGroup) =
  # first pass: propagate energy levels amongst octopi
  for y in 0 ..< octopiGroupEdgeCount:
    for x in 0 ..< octopiGroupEdgeCount:
      group.propagateEnergy(x, y)

  # second pass: all octopi that have flashed need to be reset to 0 energy level
  for y in 0 ..< octopiGroupEdgeCount:
    for x in 0 ..< octopiGroupEdgeCount:
      if group.getLuminescence(x, y) < 0:
        group.setLuminescence(x, y, 0)
