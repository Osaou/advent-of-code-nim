import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils



proc solve*(input: string): int
proc hash*(input: string): int

tests:
  solve(readFile("test.txt")) == 1320
  solve(readFile("input.txt")) == 515210



proc solve(input: string): int =
  input
    .split(",")
    .map(hash)
    .sum

#[ tests:
  hash("rn=1") == 30
  hash("cm-") == 253
  hash("qp=3") == 97
]#
proc hash(input: string): int =
  input
    .mapIt(it.ord)
    .foldl(((a + b) * 17) mod 256, 0)
