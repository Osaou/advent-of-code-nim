import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils



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



proc parseFish(input: string): seq[int] =
  input
    .split(",")
    .map(parseInt)

proc solve*(input: string): int =
  let school = input.parseFish()
  predictGrowthRate(school, 80)



tests:
  predictGrowthRate(readFile("test.txt").parseFish(), 1) == 5
  predictGrowthRate(readFile("test.txt").parseFish(), 2) == 6
  predictGrowthRate(readFile("test.txt").parseFish(), 3) == 7
  predictGrowthRate(readFile("test.txt").parseFish(), 4) == 9
  predictGrowthRate(readFile("test.txt").parseFish(), 5) == 10
  predictGrowthRate(readFile("test.txt").parseFish(), 6) == 10
  predictGrowthRate(readFile("test.txt").parseFish(), 7) == 10
  predictGrowthRate(readFile("test.txt").parseFish(), 8) == 10
  predictGrowthRate(readFile("test.txt").parseFish(), 9) == 11
  predictGrowthRate(readFile("test.txt").parseFish(), 10) == 12
  predictGrowthRate(readFile("test.txt").parseFish(), 11) == 15
  predictGrowthRate(readFile("test.txt").parseFish(), 12) == 17
  predictGrowthRate(readFile("test.txt").parseFish(), 13) == 19
  predictGrowthRate(readFile("test.txt").parseFish(), 14) == 20
  predictGrowthRate(readFile("test.txt").parseFish(), 15) == 20
  predictGrowthRate(readFile("test.txt").parseFish(), 16) == 21
  predictGrowthRate(readFile("test.txt").parseFish(), 17) == 22
  predictGrowthRate(readFile("test.txt").parseFish(), 18) == 26
  solve(readFile("test.txt")) == 5_934
  solve(readFile("input.txt")) == 383_160
