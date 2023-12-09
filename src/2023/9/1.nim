import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import elvis
import utils



proc extrapolateSensorData*(input: string): int
proc predictNextSensorValue*(data: seq[int]): int



#[ tests:
  solve(readFile("test.txt")) == 114
  solve(readFile("input.txt")) != 1842168680
  solve(readFile("input.txt")) == 1842168671
]#
proc solve*(input: string): int =
  input
    .split("\n")
    .map(extrapolateSensorData)
    .foldl(a + b, 0)

#[ tests:
  extrapolateSensorData("0 3 6 9 12 15") == 18
  extrapolateSensorData("1 3 6 10 15 21") == 28
  extrapolateSensorData("10 13 16 21 30 45") == 68
  extrapolateSensorData("-9 -12 -14 -15 -15 -14 -12 -9 -5 0 6 13 21 30 40 51 63 76 90 105 121") == 138
  extrapolateSensorData("17 40 75 124 195 314 553 1083 2269 4852 10332 21799 45683 95258 197352 404834 819561 1634448 3210609 6218318 11892083") == 22484922
]#
proc extrapolateSensorData(input: string): int =
  input
    .split(" ")
    .map(parseInt)
    .predictNextSensorValue

proc predictNextSensorValue*(data: seq[int]): int =
  let
    rateOfChange = collect:
      for i in 0..<(data.len - 1):
        let
          a = data[i]
          b = data[i + 1]

        b - a
    prevChange = data[^1]
    nextChange = rateOfChange[^1]

  if rateOfChange.allIt(it == nextChange):
    return prevChange + nextChange

  prevChange + predictNextSensorValue(rateOfChange)
