import std/strutils
import std/sequtils
import elvis
import utils



type
  Point* = tuple
    x: int
    y: int

  Line* = object
    x1*, y1*: int
    x2*, y2*: int

  Data* = tuple
    lines: seq[Line]
    cols:  int
    rows:  int



func parseLine(input: string): Line =
  let
    points: seq[string] = input.split(" -> ")
    p1 = points[0].split(',')
    p2 = points[1].split(',')
  Line(
    x1: p1[0] |> parseInt,
    y1: p1[1] |> parseInt,
    x2: p2[0] |> parseInt,
    y2: p2[1] |> parseInt,
  )



func parseData*(input: string): Data =
  let
    # parse input as lines of two points (vectors)
    lines = input
      .splitLines
      .map(parseLine)

    # compute size of seabed based on max coordinates from lines
    size = lines
      .foldl((
        cols: max(b.x1, b.x2) > a.cols ? max(b.x1, b.x2) ! a.cols,
        rows: max(b.y1, b.y2) > a.rows ? max(b.y1, b.y2) ! a.rows,
      ), (cols:0, rows:0))

  (
    lines: lines,
    cols:  size.cols,
    rows:  size.rows,
  )
