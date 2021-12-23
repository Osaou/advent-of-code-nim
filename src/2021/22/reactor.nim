import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching



type
  Cuboid* = object
    on*: bool
    x1*, x2*: int
    y1*, y2*: int
    z1*, z2*: int

func overlaps(a,b: Cuboid): bool =
  b.x1 <= a.x2 and a.x1 <= b.x2 and
  b.y1 <= a.y2 and a.y1 <= b.y2 and
  b.z1 <= a.z2 and a.z1 <= b.z2

func intersectWith(active, cut: Cuboid): seq[Cuboid] =
  if cut.x1 > active.x1:
    result &= Cuboid(
      x1: active.x1, x2: cut.x1 - 1,
      y1: active.y1, y2: active.y2,
      z1: active.z1, z2: active.z2,
    )
  if cut.x2 < active.x2:
    result &= Cuboid(
      x1: cut.x2 + 1, x2: active.x2,
      y1: active.y1, y2: active.y2,
      z1: active.z1, z2: active.z2,
    )

  let
    x1 = max(active.x1, cut.x1)
    x2 = min(active.x2, cut.x2)

  if cut.y1 > active.y1:
    result &= Cuboid(
      x1: x1, x2: x2,
      y1: active.y1, y2: cut.y1 - 1,
      z1: active.z1, z2: active.z2,
    )
  if cut.y2 < active.y2:
    result &= Cuboid(
      x1: x1, x2: x2,
      y1: cut.y2 + 1, y2: active.y2,
      z1: active.z1, z2: active.z2,
    )

  let
    y1 = max(active.y1, cut.y1)
    y2 = min(active.y2, cut.y2)

  if cut.z1 > active.z1:
    result &= Cuboid(
      x1: x1, x2: x2,
      y1: y1, y2: y2,
      z1: active.z1, z2: cut.z1 - 1,
    )
  if cut.z2 < active.z2:
    result &= Cuboid(
      x1: x1, x2: x2,
      y1: y1, y2: y2,
      z1: cut.z2 + 1, z2: active.z2,
    )

func adjustCores*(activeCoreMass: seq[Cuboid], adjustment: Cuboid): seq[Cuboid] =
  for cores in activeCoreMass:
    if cores.overlaps(adjustment):
      let keep = cores.intersectWith(adjustment)
      result.add(keep)
    else:
      result.add(cores)

  if adjustment.on:
    result.add(adjustment)

func count(cores: Cuboid): int64 =
  (cores.x2 - cores.x1 + 1) *
  (cores.y2 - cores.y1 + 1) *
  (cores.z2 - cores.z1 + 1)

func count*(activeCoreMass: seq[Cuboid]): int64 =
  activeCoreMass.foldl(a + b.count(), 0'i64)



func parseInput*(input: string): seq[Cuboid] =
  input
    .splitLines()
    .map(proc (line: string): Cuboid =
      [@state, @coords] := line.split(" ")
      [@x, @y, @z] := coords
        .split(",")
        .mapIt(it.split("=")[1].split("..").map(parseInt))

      Cuboid(on: state == "on",
        x1: x[0], x2: x[1],
        y1: y[0], y2: y[1],
        z1: z[0], z2: z[1],
      )
    )
