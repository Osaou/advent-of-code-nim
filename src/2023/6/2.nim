import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils



func parseUnit(line: string): int
func countPossibleBetterRuns(ms, mm: int): int



func solve*(input: string): int =
  [@t, @d] := input.split("\n")
  let
    time = parseUnit(t)
    distance = parseUnit(d)

  countPossibleBetterRuns(time, distance)

func parseUnit(line: string): int =
  line
    .split(":")[1]
    .replace(" ", "")
    .parseInt

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
  solve(readFile("test.txt")) == 71503
  solve(readFile("input.txt")) == 21039729
