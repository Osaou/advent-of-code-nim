import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm, deques]
import fusion/matching
import utils



proc solve*(input: string): int
proc countPossibleDamagedGearArrangements*(input: string): int
proc countPermutationsNaively*(record: string, damages: seq[int]): int
proc matchDamageReport*(record: string, damages: seq[int]): bool

tests:
  solve(readFile("test.txt")) == 21
  #solve(readFile("input.txt")) == 7753



proc solve(input: string): int =
  input
    .split("\n")
    .map(countPossibleDamagedGearArrangements)
    .foldl(a + b, 0)

#[ tests:
  countPossibleDamagedGearArrangements("???.ooo 1,1,3") == 1
]#
proc countPossibleDamagedGearArrangements(input: string): int =
  [@record, @dmg] := input.split(" ")
  let damages = dmg
    .split(",")
    .map(parseInt)

  countPermutationsNaively(record, damages)

proc countPermutationsNaively(record: string, damages: seq[int]): int =
  let dmg = record.find('?')
  if dmg < 0:
    return if record.matchDamageReport(damages): 1
           else: 0

  let
    before = record[0..<dmg]
    after = record[(dmg+1)..^1]
    a = before & "." & after
    b = before & "#" & after

  countPermutationsNaively(a, damages) +
    countPermutationsNaively(b, damages)

#[ tests:
  matchDamageReport("o.o.ooo", @[1,1,3]) == true
  matchDamageReport("oo..ooo", @[1,1,3]) == false
]#
proc matchDamageReport(record: string, damages: seq[int]): bool =
  record
    .split(".")
    .filterIt(it.len > 0)
    .mapIt(it.len) == damages
