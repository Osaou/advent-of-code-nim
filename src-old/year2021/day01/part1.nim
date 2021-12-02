import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import elvis


proc run(fileName: string): int =
  readFile(fileName)
    .split("\n")
    .filterIt(it.strip() != "")
    .map(parseInt)
    .foldl(b > a.prev ? (b, a.increases + 1) ! (b, a.increases), (prev: high(int), increases: 0))
    .increases


assert run("test.txt") == 7
echo run("input.txt")
