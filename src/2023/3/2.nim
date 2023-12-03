import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils
import matrix



func findExactlyTwoAdjacentNumbers(foundNumbers: Matrix[int], posY,posX: int): Option[seq[int]]



proc solve*(input: string): int =
  let data = input
    .split("\n")
    .toSeq
    .mapIt(it.items.toSeq)
    .matrix

  var
    hasNr = false
    currentNr = 0
    xStart = 0
    foundNumbers = matrix[int](data.rows + 2, data.cols + 2)

  for y in 0..data.lastRow:
    for x in 0..data.lastCol:
      let isCurrentInt = data[y, x].isInt

      if isCurrentInt:
        currentNr *= 10
        currentNr += data[y, x].charToInt

        if hasNr == false:
          hasNr = true
          xStart = x

      if hasNr and (not isCurrentInt or x == data.lastCol):
        let xEnd = if x == data.lastCol: x else: x-1
        for z in xStart..xEnd:
          foundNumbers[y+1, z+1] = currentNr

        hasNr = false
        currentNr = 0
        xStart = 0

  var gearRatioSum = 0

  for y in 0..data.lastRow:
    for x in 0..data.lastCol:
      if data[y, x] == '*':
        case foundNumbers.findExactlyTwoAdjacentNumbers(y, x)
        of Some(@numbers):
          gearRatioSum += numbers[0] * numbers[1]

  return gearRatioSum

func findExactlyTwoAdjacentNumbers(foundNumbers: Matrix[int], posY,posX: int): Option[seq[int]] =
  let
    Y = posY + 1
    X = posX + 1

  var
    matches = newSeq[int]()
    prevMatch = false

  for y in Y-1..Y+1:
    prevMatch = false
    for x in X-1..X+1:
      let neighbor = foundNumbers[y, x]

      if not prevMatch and neighbor > 0:
        prevMatch = true
        matches.add(neighbor)

      if neighbor <= 0:
        prevMatch = false

  if matches.len == 2:
    return some(matches)

  return none(seq[int])



tests:
  solve(readFile("test.txt")) == 467835
  solve(readFile("input.txt")) == 80703636
