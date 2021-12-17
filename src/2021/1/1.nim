import std/[strformat, strutils, sequtils, sugar]
import elvis
import utils



proc solve*(input: string): int =
  input
    .split("\n")
    .filterIt(it.strip() != "")
    .map(parseInt)
    .foldl(b > a.prev ? (b, a.increases + 1) ! (b, a.increases), (prev: high(int), increases: 0))
    .increases



tests:
  solve(readFile("test.txt")) == 7
  solve(readFile("input.txt")) == 1713
