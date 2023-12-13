import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm, deques]
import fusion/matching
import memo
import utils



proc solve*(input: string): int
proc unfoldRecord*(report: string): string
proc countPermutationsGrouped*(input: string): int
proc countPermutationsGrouped(record: string, damages: seq[int], cacheSum: int = 0): int

tests:
  solve(readFile("test.txt")) == 525152
  solve(readFile("input.txt")) == 280382734828319



proc solve(input: string): int =
  input
    .split("\n")
    .map(unfoldRecord)
    .map(countPermutationsGrouped)
    .sum

#[ tests:
  unfoldRecord(".o 1") == ".o?.o?.o?.o?.o 1,1,1,1,1"
  unfoldRecord("???.ooo 1,1,3") == "???.ooo????.ooo????.ooo????.ooo????.ooo 1,1,3,1,1,3,1,1,3,1,1,3,1,1,3"
]#
proc unfoldRecord(report: string): string =
  [@rep, @dmg] := report.split(" ")
  let
    reports = [rep].cycle(5).join("?")
    damaged = [dmg].cycle(5).join(",")

  reports & " " & damaged

#[ tests:
  countPermutationsGrouped("???.ooo 3,3") == 1
  countPermutationsGrouped("???.ooo 1,1,3") == 1
  countPermutationsGrouped("o??.ooo 1,1,3") == 1
  countPermutationsGrouped(".??..??...?oo. 1,1,3") == 4
  countPermutationsGrouped("????.o...o... 4,1,1") == 1
]#
proc countPermutationsGrouped(input: string): int =
  [@rec, @dmg] := input.split(" ")
  var
    record = rec & "."
    damages = dmg
      .split(",")
      .map(parseInt)

  countPermutationsGrouped(record, damages)

proc countPermutationsGrouped(record: string, damages: seq[int], cacheSum: int = 0): int {.memoized.} =
  if damages.len <= 0:
    return if not ('#' in record): 1
           else: 0

  var sum = cacheSum
  let
    firstDamaged = damages[0]
    restDamaged = damages[1..^1]
    maxGroupLen = (record.len - sum(restDamaged) - restDamaged.len - firstDamaged)

  for i in 0..maxGroupLen:
    if '#' in record[0..<i]:
      break

    let next = i + firstDamaged
    if next < record.len and
       record[next] != '#' and
       not ('.' in record[i..<next]):
      sum += countPermutationsGrouped(record[next+1..^1], restDamaged)

  sum
