import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils



type
  Seafloor = seq[seq[char]]
  Coord = tuple[x,y: int]

proc emptySpaceAt(seafloor: Seafloor, x,y: int): Option[Coord] =
  let xmax = seafloor[0].len - 1
  var px = x
  if px < 0:
    px = xmax
  elif px > xmax:
    px = 0

  let ymax = seafloor.len - 1
  var py = y
  if py < 0:
    py = ymax
  elif py > ymax:
    py = 0

  if seafloor[py][px] == '.':
    some((x:px, y:py))
  else:
    none[Coord]()

proc step(seafloor: Seafloor): tuple[update:Seafloor, somethingMoved:bool] =
  var somethingMoved = false
  let ymax = seafloor.len - 1

  var east = seafloor.dup()
  for y in 0 .. ymax:
    for x, cucumber in seafloor[y]:
      if cucumber == '>':
        case seafloor.emptySpaceAt(x+1, y):
          of Some((@px, @py)):
            east[y][x] = '.'
            east[py][px] = '>'
            somethingMoved = true

  var south = east.dup()
  for y in 0 .. ymax:
    for x, cucumber in east[y]:
      if cucumber == 'v':
        case east.emptySpaceAt(x, y+1):
          of Some((@px, @py)):
            south[y][x] = '.'
            south[py][px] = 'v'
            somethingMoved = true

  (update:south, somethingMoved:somethingMoved)

proc steps(seafloor: Seafloor, count: int): tuple[update:Seafloor, somethingMoved:bool] =
  var
    grid = seafloor
    canMove = true
    stepCount = 0

  while stepCount < count:
    let after = grid.step()
    grid = after.update
    canMove = after.somethingMoved
    stepCount += 1

  (update:grid, somethingMoved:canMove)

proc moveSeaCucumbers(seafloor: Seafloor): int =
  var
    grid = seafloor
    canMove = true
    stepCount = 0

  while canMove:
    let after = grid.step()
    grid = after.update
    canMove = after.somethingMoved
    stepCount += 1

  stepCount



proc solve*(input: string): int =
  let seafloor = parseGrid[char](input)
  seafloor.moveSeaCucumbers()



tests:
  # basic move
  parseGrid[char]("""
    ..........
    .>v....v..
    .......>..
    ..........
  """.unindent.strip)
    .steps(1).update
    .mapIt(it.join()).join("\n") == """
      ..........
      .>........
      ..v....v>.
      ..........
    """.unindent.strip

  # wrap-around
  parseGrid[char]("""
    ...>...
    .......
    ......>
    v.....>
    ......>
    .......
    ..vvv..
  """.unindent.strip)
    .steps(1).update
    .mapIt(it.join()).join("\n") == """
      ..vv>..
      .......
      >......
      v.....>
      >......
      .......
      ....v..
    """.unindent.strip

  # bigger example, 1 step
  parseGrid[char]("""
    v...>>.vv>
    .vv>>.vv..
    >>.>v>...v
    >>v>>.>.v.
    v>v.vv.v..
    >.>>..v...
    .vv..>.>v.
    v.v..>>v.v
    ....v..v.>
  """.unindent.strip)
    .steps(1).update
    .mapIt(it.join()).join("\n") == """
      ....>.>v.>
      v.v>.>v.v.
      >v>>..>v..
      >>v>v>.>.v
      .>v.v...v.
      v>>.>vvv..
      ..v...>>..
      vv...>>vv.
      >.v.v..v.v
    """.unindent.strip

  # bigger example, 10 steps
  parseGrid[char]("""
    v...>>.vv>
    .vv>>.vv..
    >>.>v>...v
    >>v>>.>.v.
    v>v.vv.v..
    >.>>..v...
    .vv..>.>v.
    v.v..>>v.v
    ....v..v.>
  """.unindent.strip)
    .steps(10).update
    .mapIt(it.join()).join("\n") == """
      ..>..>>vv.
      v.....>>.v
      ..v.v>>>v>
      v>.>v.>>>.
      ..v>v.vv.v
      .v.>>>.v..
      v.v..>v>..
      ..v...>v.>
      .vv..v>vv.
    """.unindent.strip

  # bigger example, 57 steps
  parseGrid[char]("""
    v...>>.vv>
    .vv>>.vv..
    >>.>v>...v
    >>v>>.>.v.
    v>v.vv.v..
    >.>>..v...
    .vv..>.>v.
    v.v..>>v.v
    ....v..v.>
  """.unindent.strip)
    .steps(57).update
    .mapIt(it.join()).join("\n") == """
      ..>>v>vv..
      ..v.>>vv..
      ..>>v>>vv.
      ..>>>>>vv.
      v......>vv
      v>v....>>v
      vvv.....>>
      >vv......>
      .>v.vv.v..
    """.unindent.strip

  # bigger example, 58 steps
  parseGrid[char]("""
    v...>>.vv>
    .vv>>.vv..
    >>.>v>...v
    >>v>>.>.v.
    v>v.vv.v..
    >.>>..v...
    .vv..>.>v.
    v.v..>>v.v
    ....v..v.>
  """.unindent.strip)
    .steps(58).update
    .mapIt(it.join()).join("\n") == """
      ..>>v>vv..
      ..v.>>vv..
      ..>>v>>vv.
      ..>>>>>vv.
      v......>vv
      v>v....>>v
      vvv.....>>
      >vv......>
      .>v.vv.v..
    """.unindent.strip

  # bigger example, 58 steps, expect no more moving
  parseGrid[char]("""
    v...>>.vv>
    .vv>>.vv..
    >>.>v>...v
    >>v>>.>.v.
    v>v.vv.v..
    >.>>..v...
    .vv..>.>v.
    v.v..>>v.v
    ....v..v.>
  """.unindent.strip)
    .steps(57).somethingMoved == true

  # bigger example, 58 steps, expect no more moving
  parseGrid[char]("""
    v...>>.vv>
    .vv>>.vv..
    >>.>v>...v
    >>v>>.>.v.
    v>v.vv.v..
    >.>>..v...
    .vv..>.>v.
    v.v..>>v.v
    ....v..v.>
  """.unindent.strip)
    .steps(58).somethingMoved == false

  # final input
  solve(readFile("test.txt")) == 58
  solve(readFile("input.txt")) == 598
