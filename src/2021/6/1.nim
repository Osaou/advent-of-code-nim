# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar



# tests
const
  expectedTestResult* = 5_934
  expectedRunResult* = 383_160



func predictGrowthRate(fishMaturity, daysLeft: int): int =
  if daysLeft <= 0:
    return 1

  let nextDay = daysLeft - 1

  if fishMaturity <= 0:
    predictGrowthRate(6, nextDay) + predictGrowthRate(8, nextDay)
  else:
    predictGrowthRate(fishMaturity - 1, nextDay)



func predictGrowthRate(school: seq[int], days: int): int =
  var amount = 0
  for fishMaturity in school:
    amount += predictGrowthRate(fishMaturity, days)

  amount



# logic
proc logic*(input: string): int =
  var school = input
    .split(",")
    .map(parseInt)

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

  predictGrowthRate(school, 80)
