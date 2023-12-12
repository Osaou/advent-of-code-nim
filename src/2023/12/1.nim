import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm, deques]
import fusion/matching
import utils



proc solve*(input: string): int
proc countPossibleDamagedGearArrangements*(input: string): int
proc extrapolateReportsNaively*(input: string): seq[string]
proc matchDamageReport*(report: string, damages: seq[int]): bool

tests:
  solve(readFile("test.txt")) == 21
  solve(readFile("input.txt")) == 7753



proc solve(input: string): int =
  input
    .split("\n")
    .map(countPossibleDamagedGearArrangements)
    .foldl(a + b, 0)

#[ tests:
  countPossibleDamagedGearArrangements("???.### 1,1,3") == 1
]#
proc countPossibleDamagedGearArrangements(input: string): int =
  [@rep, @dmg] := input.split(" ")
  let
    reports = extrapolateReportsNaively(rep)
    damaged = dmg
      .split(",")
      .map(parseInt)

  var matchingAmount = 0
  for r in reports:
    if r.matchDamageReport(damaged):
      matchingAmount += 1

  matchingAmount

proc extrapolateReportsNaively(input: string): seq[string] =
  var
    possibleVariants = newSeq[string]()
    damagedReports = [input].toDeque

  while damagedReports.len > 0:
    let
      report = damagedReports.popFirst()
      dmg = report.find('?')
    if dmg >= 0:
      let
        before = report[0..<dmg]
        after = report[(dmg+1)..^1]
        a = before & "." & after
        b = before & "#" & after

      damagedReports.addLast(a)
      damagedReports.addLast(b)
    else:
      possibleVariants.add(report)

  possibleVariants

#[ tests:
  matchDamageReport("#.#.###", @[1,1,3]) == true
  matchDamageReport("##..###", @[1,1,3]) == false
]#
proc matchDamageReport(report: string, damages: seq[int]): bool =
  report
    .split(".")
    .filterIt(it.len > 0)
    .mapIt(it.len) == damages
