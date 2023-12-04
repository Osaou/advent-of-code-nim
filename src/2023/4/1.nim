import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils



func readCardScore(card: string): int



func solve*(input: string): int =
  input
    .split("\n")
    .map(readCardScore)
    .foldl(a + b, 0)

func readCardScore(card: string): int =
  [@key, @nrs] := card
    .split(":")[1]
    .split("|")
    .mapIt(it
      .strip()
      .split(" ")
      .filterIt(it != "")
      .map(parseInt)
      .sorted()
    )

  let result = (2 ^ nrs
    .filter((x) => key.anyIt(it == x))
    .len) / 2

  result.int



tests:
  solve(readFile("test.txt")) == 13
  solve(readFile("input.txt")) == 18519
