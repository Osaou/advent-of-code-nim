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
  solve(readFile("test.txt")) == 71503
  solve(readFile("input.txt")) == 21039729
