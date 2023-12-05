import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils



type
  MappedRange = tuple
    sourceStart, sourceEnd, destinationStart: int
    range: int

  Map = tuple
    name: string
    ranges: seq[MappedRange]

proc parseMap(input: string): Map
proc deepMap(maps: seq[Map], seed: int, mapIndex: int = 0): int



proc solve*(input: string): int =
  [@s, all @m] := input.split("\n\n")
  let
    seeds = s.replace("seeds: ", "").split(" ").map(parseInt)
    maps = m.map(parseMap)

  seeds
    .mapIt(maps.deepMap(it))
    .sorted()[0]

proc parseMap(input: string): Map =
  [@def, all @ranges] := input.split("\n")
  (
    name: def.split(" ")[0],
    ranges: ranges
      .map(func (range: string): MappedRange =
        [@dest, @source, @len] := range
          .split(" ")
          .map(parseInt)
        (
          sourceStart: source,
          sourceEnd: source + (len - 1),
          destinationStart: dest,
          range: len
        )
      )
      .sorted((a, b) => a.sourceStart > b.sourceStart)
  )

proc deepMap(maps: seq[Map], seed: int, mapIndex: int = 0): int =
  var value: int = -1
  let map = maps[mapIndex]

  for r in map.ranges:
    if seed >= r.sourceStart and seed <= r.sourceEnd:
      value = r.destinationStart + (seed - r.sourceStart)

  if value < 0:
    value = seed

  let nextMap = mapIndex + 1
  if nextMap < maps.len:
    return maps.deepMap(value, nextMap)

  return value



tests:
  solve(readFile("test.txt")) == 35
  solve(readFile("input.txt")) == 265018614
