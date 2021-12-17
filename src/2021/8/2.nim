import std/[strformat, strutils, sequtils, sugar, tables, sets, math, algorithm]
import fusion/matching
import utils



func allWithSegmentAmount(input: seq[string], amount: int): seq[seq[char]] =
  input
    .filterIt(it.len == amount)
    .mapIt(it.items |> toSeq)

func withSegmentAmount(input: seq[string], amount: int): seq[char] =
  input.allWithSegmentAmount(amount)[0]

func deduceOutputValue(line: string): int =
  [@input, @output] := line
    .split(" | ")
    .mapIt(it.split(" "))

  # find #1, #4, #7, #8
  let one = input.withSegmentAmount(2)
  let four = input.withSegmentAmount(4)
  let seven = input.withSegmentAmount(3)
  let eight = input.withSegmentAmount(7)

  # three possible variants with six segments: #0, #6, #9
  let hasSixSegments = input.allWithSegmentAmount(6)

  # four is only in nine
  [@nine] := hasSixSegments.filter(sixes => four.all(x => x in sixes))

  # remove nine from possible six-segment variants
  let sixAndZero = hasSixSegments.filterIt(it != nine)

  # zero is the remaining possible six-segment variant that has all segments as one does
  [@zero] := sixAndZero.filter(sixes => one.all(x => x in sixes))

  # six is remainder after we remove zero from possible six-segment variants
  [@six] := sixAndZero.filterIt(it != zero)

  # at this point:
  # found: 0, 1, 4, 6, 7, 8, 9
  # remaining: 2, 3, 5

  # three possible variants with five segments: #2, #3, #5
  let hasFiveSegments = input.allWithSegmentAmount(5)

  # one is only in three
  [@three] := hasFiveSegments.filter(sixes => one.all(x => x in sixes))

  # remove three from possible five-segment variants
  let twoAndFive = hasFiveSegments.filterIt(it != three)

  # complement of zero, three and four -> bottom-left segment
  let bottomLeftSegment = zero
    .filterIt(it notin three)
    .filterIt(it notin four)[0]

  # between two and five, two is the one that has bottom-left segment lit up
  [@two] := twoAndFive.filterIt(bottomLeftSegment in it)

  # five is remainder after we remove two from possible six-segment variants
  [@five] := twoAndFive.filterIt(it != two)

  # build look-up-table for all numbers
  let lut = collect(initTable()):
    for index, segments in @[zero, one, two, three, four, five, six, seven, eight, nine]:
      { segments.sorted().join(): $(index) }

  # figure out what all output numbers mean by using the look-up-table
  output
    .mapIt(it.items |> toSeq)
    .mapIt(it.sorted)
    .mapIt(it.join)
    .mapIt(lut[it])
    .join() |> parseInt



proc solve*(input: string): int =
  input
    .splitLines()
    .map(deduceOutputValue)
    .sum()



tests:
  deduceOutputValue("acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf") == 5353
  solve(readFile("test.txt")) == 61_229
  solve(readFile("input.txt")) == 1_011_284
