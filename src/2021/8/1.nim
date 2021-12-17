import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils



func solve*(input: string): int =
  input
    .splitLines()
    .mapIt(it.split(" | ")[1])
    .mapIt(it
      .split(" ")
      .filterIt(it.len == 2 or  #1
                it.len == 3 or  #7
                it.len == 4 or  #4
                it.len == 7)    #8
      .len()
    )
    .sum()



tests:
  solve(readFile("test.txt")) == 26
  solve(readFile("input.txt")) == 532
