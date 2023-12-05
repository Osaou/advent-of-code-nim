import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils



type
  SeedRange = tuple
    s1, len: int

  Seeds = tuple
    ranges: seq[SeedRange]

  MappedRange = tuple
    sourceStart, sourceEnd, destinationStart: int
    range: int

  Map = tuple
    name: string
    ranges: seq[MappedRange]

proc parseSeeds(input: string): Seeds
proc parseMap(input: string): Map
proc deepMap(maps: seq[Map], seed: int, mapIndex: int = 0): int



proc solve*(input: string): int =
  [@s, all @m] := input.split("\n\n")
  let
    seeds = parseSeeds(s)
    maps = m.map(parseMap)

  var lowest = int.high

  var i = 1
  for r in seeds.ranges:
    echo "processing seed range ", i, "/", seeds.ranges.len, ": ", r
    i += 1

    let
      first = r.s1
      last = r.s1 + (r.len - 1)

    for s in first..last:
      let location = maps.deepMap(s)
      if location < lowest:
        lowest = location

  lowest

proc parseSeeds(input: string): Seeds =
  let
    seedRanges = input
      .replace("seeds: ", "")
      .split(" ")
      .map(parseInt)
    rangeCount = seedRanges.len div 2

  var seeds = newSeq[SeedRange](rangeCount)

  for i in 0..<rangeCount:
    let
      s1 = seedRanges[i * 2]
      len = seedRanges[i * 2 + 1]

    seeds[i] = (s1: s1, len: len)

  (ranges: seeds)

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
      break

  if value < 0:
    value = seed

  let nextMap = mapIndex + 1
  if nextMap < maps.len:
    return maps.deepMap(value, nextMap)

  return value



tests:
  solve(readFile("test.txt")) == 46
  solve(readFile("input.txt")) == 63179500
  solve(readFile("richo.txt")) == 79874951
