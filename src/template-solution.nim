import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils



proc solve*(input: string): int
proc compute*(input: string): int

tests:
  solve(readFile("test.txt")) == 0
  #solve(readFile("input.txt")) == 0



proc solve(input: string): int =
  input.
    compute()

#[ tests:
  compute("123") == 0
]#
proc compute(input: string): int =
  0
