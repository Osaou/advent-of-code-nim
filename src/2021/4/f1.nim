# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import utils



# tests
const
  expectedTestResult* = 1
  expectedRunResult* = 2



type
  Board = tuple
    rowSums: seq[int]
    colSums: seq[int]

func parseBoardRow(row: string): seq[int] =
  row
    .split(" ")
    .filterIt(it.len > 0)
    .map(parseInt)

# logic
proc logic*(input: string): int =
  var
    lines = input.splitLines
    gameData = lines[0].split(",").map(parseInt)
    boards = newSeq[Board]()

  # parse game boards
  lines.delete(0..0)
  while lines.len > 5:
    echo "NEW BOARD"
    let
      row1 = parseBoardRow(lines[1])
      row2 = parseBoardRow(lines[2])
      row3 = parseBoardRow(lines[3])
      row4 = parseBoardRow(lines[4])
      row5 = parseBoardRow(lines[5])
    echo "  row1 ", row1
    echo "  row2 ", row2
    echo "  row3 ", row3
    echo "  row4 ", row4
    echo "  row5 ", row5
    let
      rows = @[row1, row2, row3, row4, row5]
      cols = rows.transposeMatrix()

    echo "  ROWS ", rows
    echo "  COLS ", cols

    let board = (
      rowSums: rows.mapIt(it.foldl(a+b, 0)),
      colSums: cols.mapIt(it.foldl(a+b, 0)),
    )
    boards.add(board)

    echo "  rowSums ", board.rowSums
    echo "  colSums ", board.colSums

    # remove this board data, 5 lines of numbers + 1 empty line
    lines.delete(0..5)

  # start the game!
  echo ""
  echo "STARTING THE GAME!"
  while gameData.len > 0:
    let drawn = gameData[0]
    var index = 0
    echo "DRAWN: ", drawn

    #for index, board in boards:
    while index < boards.len:
      let board = boards[index]
      #board.rowSums.apply(proc(x:int): int = x - drawn)
      #board.colSums.apply(x => x - drawn)
      let adjustedBoard = (
        rowSums: board.rowSums.mapIt(it - drawn),
        colSums: board.colSums.mapIt(it - drawn),
      )
      echo "  board ", (index+1), " after adjustments: ", adjustedBoard

      # check for bingo
      if adjustedBoard.rowSums.filterIt(it == 0).len > 0 or adjustedBoard.colSums.filterIt(it == 0).len > 0:
        echo "WINNER after ", drawn, " was drawn!"
        break

      # replace board with adjusted data
      boards.delete(index..index)
      boards.insert(adjustedBoard, index)

      index += 1

    # move on to the next number
    gameData.delete(0..0)

  0
