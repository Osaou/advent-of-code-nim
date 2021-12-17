import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import elvis



type
  BoardPos = tuple
    nr: int
    marked: bool

  Board = tuple
    numbers: seq[seq[BoardPos]]

func checkForBingo(board: Board): bool
func checkForBingo(nrs: seq[BoardPos]): bool
func parseBoardRow(row: string): seq[BoardPos]



func solve*(input: string): int =
  var
    lines = input.splitLines
    gameData = lines[0].split(",").map(parseInt)
    boards = newSeq[Board]()

  # parse game boards
  lines.delete(0..0)
  while lines.len > 5:
    let
      row1 = parseBoardRow(lines[1])
      row2 = parseBoardRow(lines[2])
      row3 = parseBoardRow(lines[3])
      row4 = parseBoardRow(lines[4])
      row5 = parseBoardRow(lines[5])

    let board = (numbers: @[row1, row2, row3, row4, row5])
    boards.add(board)

    # remove this board data, 5 lines of numbers + 1 empty line
    lines.delete(0..5)

  # start the game!
  while gameData.len > 0:
    let drawn = gameData[0]

    # iterate over all boards
    var index = 0
    while index < boards.len:
      let board = boards[index]
      let adjustedBoard = (
        numbers: board.numbers
          .map(row => row
            .map(col => col.nr == drawn ? (nr:drawn, marked:true) ! (nr:col.nr, marked:col.marked))
          )
      )

      # check for bingo
      if checkForBingo(adjustedBoard):
        let remainingUnmarked = adjustedBoard.numbers
          .map(row => row
            .foldl(a + (b.marked == false ? b.nr ! 0), 0)
          )
          .foldl(a+b, 0)

        return remainingUnmarked * drawn

      # replace board with adjusted data
      boards.delete(index..index)
      boards.insert(adjustedBoard, index)

      index += 1

    # move on to the next number
    gameData.delete(0..0)

  # should not get here
  quit 1



func parseBoardRow(row: string): seq[BoardPos] =
  row
    .split(" ")
    .filterIt(it.len > 0)
    .map(parseInt)
    .mapIt((nr:it, marked:false))

func checkForBingo(board: Board): bool =
  # check all rows
  for nrs in board.numbers:
    if checkForBingo(nrs):
      return true
  # check all columns
  for nrs in board.numbers.transposeMatrix():
    if checkForBingo(nrs):
      return true
  # darn, no bingo
  return false

func checkForBingo(nrs: seq[BoardPos]): bool =
  nrs
    .filterIt(it.marked == false)
    .len == 0



tests:
  solve(readFile("test.txt")) == 4512
  solve(readFile("input.txt")) == 51776
