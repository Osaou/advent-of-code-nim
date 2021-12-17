import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils



func predictGrowthRate(school: seq[int64], days: int): int64 =
  var fish = school.toCountTable

  for day in 1 .. days:
    var fishNextDay = initCountTable[int64](9)

    for maturity, count in fish:
      if maturity > 0:
        fishNextDay[maturity - 1] = count
      else:
        fishNextDay.inc(6, count)
        fishNextDay[8] = count

    fish = fishNextDay

  fish.values.toSeq.sum



proc solve*(input: string): int64 =
  var school = input
    .split(",")
    .map(parseInt)
    .mapIt(it.int64)

  predictGrowthRate(school, 256)



tests:
  solve(readFile("test.txt")) == 26_984_457_539
  solve(readFile("input.txt")) == 1_721_148_811_504
