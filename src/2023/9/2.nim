import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import elvis
import utils



proc extrapolateSensorData*(input: string): int
proc predictPreviousSensorValue*(data: seq[int]): int



#[ tests:
  solve(readFile("test.txt")) == 2
  solve(readFile("input.txt")) == 903
]#
proc solve*(input: string): int =
  input
    .split("\n")
    .map(extrapolateSensorData)
    .foldl(a + b, 0)

#[ tests:
  extrapolateSensorData("0 3 6 9 12 15") == -3
  extrapolateSensorData("1 3 6 10 15 21") == 0
  extrapolateSensorData("10 13 16 21 30 45") == 5
]#
proc extrapolateSensorData(input: string): int =
  input
    .split(" ")
    .map(parseInt)
    .reversed
    .predictPreviousSensorValue

proc predictPreviousSensorValue*(data: seq[int]): int =
  let
    rateOfChange = collect:
      for i in 0..<(data.len - 1):
        let
          a = data[i]
          b = data[i + 1]

        a - b
    prevChange = data[^1]
    nextChange = rateOfChange[^1]

  if rateOfChange.allIt(it == nextChange):
    return prevChange - nextChange

  prevChange - predictPreviousSensorValue(rateOfChange)
