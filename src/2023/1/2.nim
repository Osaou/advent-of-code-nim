import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, re]
import fusion/matching
import utils



proc parseNrs(line: string): int =
  let
    allNumbers = line
      .strip()
      .toLower()
      #[.multiReplace(@[
        (re"zero", "z0o"),
        (re"one", "o1e"),
        (re"two", "t2o"),
        (re"three", "t3e"),
        (re"four", "f4r"),
        (re"five", "f5e"),
        (re"six", "s6x"),
        (re"seven", "s7n"),
        (re"eight", "e8t"),
        (re"nine", "n9e"),
      ])]#
      .replace(re"zero", "z0o")
      .replace(re"one", "o1e")
      .replace(re"two", "t2o")
      .replace(re"three", "t3e")
      .replace(re"four", "f4r")
      .replace(re"five", "f5e")
      .replace(re"six", "s6x")
      .replace(re"seven", "s7n")
      .replace(re"eight", "e8t")
      .replace(re"nine", "n9e")
      .replace(re"\D", "")
      .mapIt(int(it) - int('0'))
    first = allNumbers[0]
    last = allNumbers[^1]

  first * 10 + last

proc solve*(input: string): int =
  input
    .split("\n")
    .filterIt(it.strip() != "")
    .map(parseNrs)
    .foldl(a + b, 0)



tests:
  parseNrs("18") == 18
  parseNrs("c5") == 55
  parseNrs("seven") == 77
  parseNrs("oneight2") == 12
  parseNrs("nineight") == 98
  parseNrs("sevenine") == 79
  parseNrs("threeight") == 38
  parseNrs("fiveight") == 58
  parseNrs("twone") == 21
  parseNrs("nineeightseven") == 97
  parseNrs("pqoner3s7tu8vwx") == 18
  parseNrs("pqoner3s7tu8vwsevenx") == 17
  parseNrs("pqr3s7tuvwxeight") == 38
  parseNrs("5gregrew-9") == 59
  solve(readFile("test.txt")) == 142
  solve(readFile("test2.txt")) == 281
  solve(readFile("input.txt")) != 53355 # wrong answer #1
  solve(readFile("input.txt")) == 53348
