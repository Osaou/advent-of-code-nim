import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm, deques]
import fusion/matching
import utils
import matrix



type
  Pipe = tuple
    x,y: int
    pipe: char

proc solve*(input: string): int
proc markEnclosedPipePath(pipes: Matrix): seq[Pipe]
proc findStepFromStart(pipes: Matrix, start: Pipe): Pipe
proc findNextStep*(pipes: Matrix, previous, current: Pipe): Pipe
proc tracePath(m: Matrix, path: seq[Pipe]): Matrix
proc expand(m: Matrix): Matrix
proc floodFill(m: Matrix): Matrix
proc compress(m: Matrix): Matrix

tests:
  solve(readFile("test3.txt")) == 4
  solve(readFile("test4.txt")) == 4
  solve(readFile("test5.txt")) == 8
  solve(readFile("test6.txt")) == 10
  solve(readFile("input.txt")) == 461



proc solve(input: string): int =
  let
    pipes = input.split("\n").mapIt(it.toSeq).matrix
    path = pipes.markEnclosedPipePath()

  pipes
    .tracePath(path)
    .expand()
    .floodFill()
    .compress()
    .data
    .filterIt(it == ' ')
    .len

proc markEnclosedPipePath(pipes: Matrix): seq[Pipe] =
  let
    S = pipes.data.find('S')
    start = (
      x: S mod pipes.cols,
      y: S div pipes.cols,
      pipe: 'S'
    )
    first = pipes.findStepFromStart(start)
  var
    previous = start
    current = first
    currentPipe: char
    step: Pipe
    steps = @[start]

  while true:
    steps.add(current)

    currentPipe = pipes[current.y, current.x]
    step = pipes.findNextStep(previous, current)

    if step.pipe == 'S':
      break

    previous = current
    current = step

  steps

proc findStepFromStart(pipes: Matrix, start: Pipe): Pipe =
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
      sx = start.x + (x - 1)
      sy = start.y + (y - 1)

    if sx < 0 or sx > pipes.lastCol or
       sy < 0 or sy > pipes.lastRow:
      continue

    let step = (
      x: sx,
      y: sy,
      pipe: pipes[sy, sx]
    )

    if not target.anyIt(it == step.pipe):
      continue

    return step

  doAssert true, "doh"

#[ tests:
  "abcde,fghij,klmno,pqrst,uvwxy".split(",").mapIt(it.toSeq).matrix.findNextStep((x:2, y:1, pipe:' '), (x:3, y:1, pipe: '-')) == (x:4, y:1, pipe: 'j')
  "abcde,fghij,klmno,pqrst,uvwxy".split(",").mapIt(it.toSeq).matrix.findNextStep((x:4, y:1, pipe:' '), (x:3, y:1, pipe: '-')) == (x:2, y:1, pipe: 'h')
  "abcde,fghij,klmno,pqrst,uvwxy".split(",").mapIt(it.toSeq).matrix.findNextStep((x:1, y:2, pipe:' '), (x:1, y:3, pipe: '|')) == (x:1, y:4, pipe: 'v')
  "abcde,fghij,klmno,pqrst,uvwxy".split(",").mapIt(it.toSeq).matrix.findNextStep((x:1, y:4, pipe:' '), (x:1, y:3, pipe: '|')) == (x:1, y:2, pipe: 'l')
  "abcde,fghij,klmno,pqrst,uvwxy".split(",").mapIt(it.toSeq).matrix.findNextStep((x:2, y:1, pipe:' '), (x:1, y:1, pipe: 'F')) == (x:1, y:2, pipe: 'l')
  "abcde,fghij,klmno,pqrst,uvwxy".split(",").mapIt(it.toSeq).matrix.findNextStep((x:1, y:2, pipe:' '), (x:1, y:1, pipe: 'F')) == (x:2, y:1, pipe: 'h')
  "abcde,fghij,klmno,pqrst,uvwxy".split(",").mapIt(it.toSeq).matrix.findNextStep((x:0, y:1, pipe:' '), (x:1, y:1, pipe: '7')) == (x:1, y:2, pipe: 'l')
  "abcde,fghij,klmno,pqrst,uvwxy".split(",").mapIt(it.toSeq).matrix.findNextStep((x:1, y:2, pipe:' '), (x:1, y:1, pipe: '7')) == (x:0, y:1, pipe: 'f')
  "abcde,fghij,klmno,pqrst,uvwxy".split(",").mapIt(it.toSeq).matrix.findNextStep((x:2, y:1, pipe:' '), (x:1, y:1, pipe: 'L')) == (x:1, y:0, pipe: 'b')
  "abcde,fghij,klmno,pqrst,uvwxy".split(",").mapIt(it.toSeq).matrix.findNextStep((x:1, y:0, pipe:' '), (x:1, y:1, pipe: 'L')) == (x:2, y:1, pipe: 'h')
  "abcde,fghij,klmno,pqrst,uvwxy".split(",").mapIt(it.toSeq).matrix.findNextStep((x:0, y:1, pipe:' '), (x:1, y:1, pipe: 'J')) == (x:1, y:0, pipe: 'b')
  "abcde,fghij,klmno,pqrst,uvwxy".split(",").mapIt(it.toSeq).matrix.findNextStep((x:1, y:0, pipe:' '), (x:1, y:1, pipe: 'J')) == (x:0, y:1, pipe: 'f')
]#
proc findNextStep(pipes: Matrix, previous, current: Pipe): Pipe =
  var
    dx = 0
    dy = 0

  case current.pipe
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

  let
    sx = current.x + dx
    sy = current.y + dy
  (
    x: sx,
    y: sy,
    pipe: pipes[sy, sx]
  )

proc tracePath(m: Matrix, path: seq[Pipe]): Matrix =
  var enclosed = matrix[char](m.rows, m.cols, ' ')

  for step in path:
    enclosed[step.y, step.x] = step.pipe

  enclosed

proc expand(m: Matrix): Matrix =
  var expanded = matrix[char](m.rows * 3, m.cols * 3, ' ')

  for y in 0..<m.rows:
    for x in 0..<m.cols:
      let
        pipe = m[y, x]
        ex = 3*x + 1
        ey = 3*y + 1

      expanded[ey, ex] = pipe

      case pipe
      of 'S':
        for sy in [-1,0,1]:
          for sx in [-1,0,1]:
            expanded[ey + sx, ex + sy] = pipe
      of '-':
        expanded[ey, ex - 1] = pipe
        expanded[ey, ex + 1] = pipe
      of '|':
        expanded[ey - 1, ex] = pipe
        expanded[ey + 1, ex] = pipe
      of 'F':
        expanded[ey, ex + 1] = pipe
        expanded[ey + 1, ex] = pipe
      of '7':
        expanded[ey, ex - 1] = pipe
        expanded[ey + 1, ex] = pipe
      of 'L':
        expanded[ey, ex + 1] = pipe
        expanded[ey - 1, ex] = pipe
      of 'J':
        expanded[ey, ex - 1] = pipe
        expanded[ey - 1, ex] = pipe
      else:
        discard

  expanded

proc floodFill(m: Matrix): Matrix =
  var
    filled = m
    queue = [ (x:0, y:0) ].toDeque

  while queue.len > 0:
    let at = queue.popFirst()
    if filled[at.y, at.x] != ' ':
      continue

    filled[at.y, at.x] = 'O'

    for dir in [1,3,5,7]:
      let
        x = dir mod 3
        y = dir div 3
        sx = at.x + (x - 1)
        sy = at.y + (y - 1)
        step = (
          x: sx,
          y: sy
        )

      if step.x < 0 or step.x > m.lastCol or
         step.y < 0 or step.y > m.lastRow:
        continue

      if filled[sy, sx] == ' ':
        queue.addLast(step)

  filled

proc compress(m: Matrix): Matrix =
  var compressed = matrix[char](m.rows div 3, m.cols div 3, ' ')

  for y in 0..<compressed.rows:
    for x in 0..<compressed.cols:
      let
        ex = 3*x + 1
        ey = 3*y + 1
        pipe = m[ey, ex]

      compressed[y, x] = pipe

  compressed
