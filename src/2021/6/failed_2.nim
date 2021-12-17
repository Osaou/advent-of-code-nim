import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils



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



proc solve*(input: string): int64 =
  var school = input
    .split(",")
    .map(parseInt)
    .mapIt(it.int64)

  predictGrowthRate(school, 256)



tests:
  solve(readFile("test.txt")) == 26_984_457_539
