import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils



func parseUnit(line: string): seq[int]
func beatRecordTimes(runs: seq[tuple[ms, mm: int]]): int
func countPossibleBetterRuns(ms, mm: int): int



func solve*(input: string): int =
  [@t, @d] := input.split("\n")
  let
    time = parseUnit(t)
    distance = parseUnit(d)
    recordRuns = zip(time, distance)

  beatRecordTimes(recordRuns)

func parseUnit(line: string): seq[int] =
  line
    .split(":")[1]
    .split(" ")
    .mapIt(it.strip)
    .filterIt(it != "")
    .map(parseInt)

func beatRecordTimes(runs: seq[tuple[ms, mm: int]]): int =
  runs
    .mapIt(countPossibleBetterRuns(it.ms, it.mm))
    .foldl(a * b, 1)

func countPossibleBetterRuns(ms, mm: int): int =
  let half = ms div 2
  var wins = 0

  if ms mod 2 == 0:
    wins += 1

  for t in (half + 1) ..< ms:
    if t * (ms - t) > mm:
      wins += 2
    else:
      break

  wins



tests:
  countPossibleBetterRuns(7, 9) == 4
  countPossibleBetterRuns(15, 40) == 8
  countPossibleBetterRuns(30, 200) == 9
  solve(readFile("test.txt")) == 288
  solve(readFile("input.txt")) == 114400
