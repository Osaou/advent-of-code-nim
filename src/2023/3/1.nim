import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils
import matrix



func hasAdjacentSymbol(data: Matrix, y, xStart, xEnd, nr: int): bool
func isSymbol(entry: char): bool



proc solve*(input: string): int =
  let data = input
    .split("\n")
    .toSeq
    .mapIt(it.items.toSeq)
    .matrix

  var
    resultSum = 0
    hasNr = false
    currentNr = 0
    xStart = 0

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
        if data.hasAdjacentSymbol(y, xStart, xEnd, currentNr):
          resultSum += currentNr

        hasNr = false
        currentNr = 0
        xStart = 0

  return resultSum

func hasAdjacentSymbol(data: Matrix, y, xStart, xEnd, nr: int): bool =
  if xStart > 0:
    if y > 0 and            data[y - 1, xStart - 1].isSymbol: return true
    if                      data[y + 0, xStart - 1].isSymbol: return true
    if y < data.lastRow and data[y + 1, xStart - 1].isSymbol: return true

  for x in xStart..xEnd:
    if y > 0 and            data[y - 1, x].isSymbol: return true
    if y < data.lastRow and data[y + 1, x].isSymbol: return true

  if xEnd < data.lastCol:
    if y > 0 and            data[y - 1, xEnd + 1].isSymbol: return true
    if                      data[y + 0, xEnd + 1].isSymbol: return true
    if y < data.lastRow and data[y + 1, xEnd + 1].isSymbol: return true

  return false

func isSymbol(entry: char): bool =
  return entry != '.' and not entry.isInt



tests:
  # symbols
  isSymbol('.') == false
  isSymbol('0') == false
  isSymbol('9') == false
  isSymbol('a') == true
  isSymbol('#') == true
  isSymbol('+') == true
  isSymbol('*') == true
  isSymbol('$') == true
  # adjacents
  # corner falsy
  hasAdjacentSymbol(matrix(@[
    "467.".toSeq,
    "....".toSeq,
  ]), 0, 0,2, 467) == false
  hasAdjacentSymbol(matrix(@[
    ".467".toSeq,
    "....".toSeq,
  ]), 0, 1,3, 467) == false
  hasAdjacentSymbol(matrix(@[
    "....".toSeq,
    ".467".toSeq,
  ]), 1, 1,3, 467) == false
  hasAdjacentSymbol(matrix(@[
    "....".toSeq,
    "467.".toSeq,
  ]), 1, 0,2, 467) == false
  # corner truthy
  hasAdjacentSymbol(matrix(@[
    "467.".toSeq,
    "...a".toSeq,
  ]), 0, 0,2, 467) == true
  hasAdjacentSymbol(matrix(@[
    ".467".toSeq,
    "$...".toSeq,
  ]), 0, 1,3, 467) == true
  hasAdjacentSymbol(matrix(@[
    "*...".toSeq,
    ".467".toSeq,
  ]), 1, 1,3, 467) == true
  hasAdjacentSymbol(matrix(@[
    "...#".toSeq,
    "467.".toSeq,
  ]), 1, 0,2, 467) == true
  # edges
  hasAdjacentSymbol(matrix(@[
    "....".toSeq,
    "617*".toSeq,
    "....".toSeq,
  ]), 1, 0,2, 617) == true
  # middle
  hasAdjacentSymbol(matrix(@[
    ".....".toSeq,
    ".617.".toSeq,
    ".....".toSeq,
  ]), 1, 1,3, 617) == false
  hasAdjacentSymbol(matrix(@[
    ".....".toSeq,
    ".617%".toSeq,
    ".....".toSeq,
  ]), 1, 1,3, 617) == true
  hasAdjacentSymbol(matrix(@[
    "..=..".toSeq,
    ".617.".toSeq,
    ".....".toSeq,
  ]), 1, 1,3, 617) == true
  hasAdjacentSymbol(matrix(@[
    ".....".toSeq,
    ".617.".toSeq,
    ".#...".toSeq,
  ]), 1, 1,3, 617) == true
  # solves
  solve("""467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..""") == 4361
