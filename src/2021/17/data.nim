import std/[strutils, sequtils, sugar]



type

  Point* = object
    x*, y*: int
    vx*, vy*: int

  TargetAxis* = object
    lo*: int
    hi*: int



func parseTargetArea*(input: string): seq[TargetAxis] =
  input
    .replace("target area: ", "")
    .replace("x=", "")
    .replace("y=", "")
    .split(", ")
    .map(slice => slice
      .split("..")
      .map(parseInt)
    )
    .mapIt(TargetAxis( lo:it[0], hi:it[1] ))



func inTargetArea*(p: Point, x,y: TargetAxis): bool =
  p.x >= x.lo and p.x <= x.hi and
  p.y >= y.lo and p.y <= y.hi



func step*(p: var Point) =
  let
    x = p.x + p.vx
    y = p.y + p.vy

    vx = if p.vx > 0:
           p.vx - 1
         elif p.vx < 0:
           p.vx + 1
         else:
           0
    vy = p.vy - 1

  p.x = x
  p.y = y
  p.vx = vx
  p.vy = vy
