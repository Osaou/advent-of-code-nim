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
  var answer = newSeq[int]()

  for previousRecord in runs:
    (@ms, @mm) := previousRecord
    let wins = countPossibleBetterRuns(ms, mm)
    answer.add(wins)

  answer.foldl(a * b, 1)

func countPossibleBetterRuns(ms, mm: int): int =
  let half = ms div 2
  var wins = initHashSet[int]()

  for i in 0..(ms - 1):
    let
      h1 = half - i
      h2 = half + i

    var added = false

    if h1 * (ms - h1) > mm:
      wins.incl(h1)
      added = true

    if h2 * (ms - h2) > mm:
      wins.incl(h2)
      added = true

    if not added:
      break

  wins.len



tests:
  countPossibleBetterRuns(7, 9) == 4
  countPossibleBetterRuns(15, 40) == 8
  countPossibleBetterRuns(30, 200) == 9
  solve(readFile("test.txt")) == 288
  solve(readFile("input.txt")) == 114400
