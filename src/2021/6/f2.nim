# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import utils



# tests
const
  expectedTestResult* = 26_984_457_539
  expectedRunResult* = 1_721_148_811_504



func predictGrowthRate(fishMaturity, daysLeft: int64): int64 =
  if daysLeft <= 0:
    return 1

  let nextDay = daysLeft - 1

  if fishMaturity <= 0:
    predictGrowthRate(6, nextDay) + predictGrowthRate(8, nextDay)
  else:
    predictGrowthRate(fishMaturity - 1, nextDay)



proc predictGrowthRate(school: seq[int64], days: int64): int64 =
  var amount: int64 = 0
  for index, fishMaturity in school:
    amount += predictGrowthRate(fishMaturity, days)
    echo fmt"predicted {(index+1)}/{school.len} fish"

  amount



# logic
proc logic*(input: string): int64 =
  var school = input
    .split(",")
    .map(parseInt)
    .mapIt(it.int64)

  #assert predictGrowthRate(school.dup(), 1) == 5
  #assert predictGrowthRate(school.dup(), 2) == 6
  #assert predictGrowthRate(school.dup(), 3) == 7
  #assert predictGrowthRate(school.dup(), 4) == 9
  #assert predictGrowthRate(school.dup(), 5) == 10
  #assert predictGrowthRate(school.dup(), 6) == 10
  #assert predictGrowthRate(school.dup(), 7) == 10
  #assert predictGrowthRate(school.dup(), 8) == 10
  #assert predictGrowthRate(school.dup(), 9) == 11
  #assert predictGrowthRate(school.dup(), 10) == 12
  #assert predictGrowthRate(school.dup(), 11) == 15
  #assert predictGrowthRate(school.dup(), 12) == 17
  #assert predictGrowthRate(school.dup(), 13) == 19
  #assert predictGrowthRate(school.dup(), 14) == 20
  #assert predictGrowthRate(school.dup(), 15) == 20
  #assert predictGrowthRate(school.dup(), 16) == 21
  #assert predictGrowthRate(school.dup(), 17) == 22
  #assert predictGrowthRate(school.dup(), 18) == 26
  #assert predictGrowthRate(school.dup(), 80) == expectedTestResult

  predictGrowthRate(school, 256)
