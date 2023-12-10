import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils
import matrix



type Position = tuple
  x,y: int

proc solve*(input: string): int
proc countStepsAlongPath(pipes: Matrix): int
proc findStepFromStart(pipes: Matrix, start: Position): Position
proc findNextStep*(pipe: char, previous, current: Position): Position

tests:
  solve(readFile("test.txt")) == 4
  solve(readFile("test2.txt")) == 8
  solve(readFile("input.txt")) == 6909



proc solve(input: string): int =
  input
    .split("\n")
    .mapIt(it.toSeq)
    .matrix
    .countStepsAlongPath() div 2

proc countStepsAlongPath(pipes: Matrix): int =
  let
    S = pipes.data.find('S')
    start = (
      x: S mod pipes.cols,
      y: S div pipes.cols
    )
    first = pipes.findStepFromStart(start)
  var
    previous = start
    current = first
    currentPipe: char
    step: Position
    steps = 1

  while true:
    steps += 1

    currentPipe = pipes[current.y, current.x]
    step = currentPipe.findNextStep(previous, current)

    if pipes[step.y, step.x] == 'S':
      break

    previous = current
    current = step

  steps

proc findStepFromStart(pipes: Matrix, start: Position): Position =
  for dir in [1,3,5,7]:
    var target: seq[char]
    case dir
    # top
    of 1: target = "7|F".toSeq
    # left
    of 3: target = "F-L".toSeq
    # right
    of 5: target = "7-J".toSeq
    # bottom
    of 7: target = "J|L".toSeq
    else: continue

    let
      x = dir mod 3
      y = dir div 3
      step = (
        x: start.x + (x - 1),
        y: start.y + (y - 1)
      )

    if step.x < 0 or step.x > pipes.lastCol or
       step.y < 0 or step.y > pipes.lastRow:
      continue

    let pipe = pipes[step.y, step.x]
    if not target.anyIt(it == pipe):
      continue

    return step

  doAssert true, "doh"

#[ tests:
  '-'.findNextStep((x:2, y:1), (x:3, y:1)) == (x:4, y:1)
  '-'.findNextStep((x:4, y:1), (x:3, y:1)) == (x:2, y:1)
  '|'.findNextStep((x:1, y:2), (x:1, y:3)) == (x:1, y:4)
  '|'.findNextStep((x:1, y:4), (x:1, y:3)) == (x:1, y:2)
  'F'.findNextStep((x:2, y:1), (x:1, y:1)) == (x:1, y:2)
  'F'.findNextStep((x:1, y:2), (x:1, y:1)) == (x:2, y:1)
  '7'.findNextStep((x:0, y:1), (x:1, y:1)) == (x:1, y:2)
  '7'.findNextStep((x:1, y:2), (x:1, y:1)) == (x:0, y:1)
  'L'.findNextStep((x:2, y:1), (x:1, y:1)) == (x:1, y:0)
  'L'.findNextStep((x:1, y:0), (x:1, y:1)) == (x:2, y:1)
  'J'.findNextStep((x:0, y:1), (x:1, y:1)) == (x:1, y:0)
  'J'.findNextStep((x:1, y:0), (x:1, y:1)) == (x:0, y:1)
]#
proc findNextStep(pipe: char, previous, current: Position): Position =
  var
    dx = 0
    dy = 0

  case pipe
  of '-':
    if previous.x < current.x:
      dx = 1
    else:
      dx = -1
  of '|':
    if previous.y < current.y:
      dy = 1
    else:
      dy = -1
  of 'F':
    if previous.x > current.x:
      dy = 1
    else:
      dx = 1
  of '7':
    if previous.x < current.x:
      dy = 1
    else:
      dx = -1
  of 'L':
    if previous.x > current.x:
      dy = -1
    else:
      dx = 1
  of 'J':
    if previous.x < current.x:
      dy = -1
    else:
      dx = -1
  else:
    discard

  (
    x: current.x + dx,
    y: current.y + dy,
  )
