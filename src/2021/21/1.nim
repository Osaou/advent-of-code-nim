import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils



type
  Player = ref object
    id: int
    position: int
    score: int

  DieRoll = tuple
    value: int
    rollCount: int

proc deterministicDie(): iterator(): DieRoll =
  result = iterator(): DieRoll =
    var rollCount = 0
    while true:
      for nr in 1..100:
        rollCount += 1
        yield (value:nr, rollCount:rollCount)

let die = deterministicDie()
proc roll(): DieRoll =
  die()

proc nextPlayer(current, one, two: Player): Player =
  if current.id == two.id:
    one
  else:
    two



proc solve*(input: string): int =
  [@a, @b] := input
    .replace("Player 1 starting position: ", "")
    .replace("Player 2 starting position: ", "")
    .splitLines()
    .map(parseInt)

  var
    one = Player(id:1, position:a-1, score:0)
    two = Player(id:2, position:b-1, score:0)
    currentPlayer = two

  let die = deterministicDie()
  proc roll(): DieRoll =
    die()

  while currentPlayer.score < 1000:
    currentPlayer = currentPlayer.nextPlayer(one, two)

    let rolls = roll().value + roll().value + roll().value

    currentPlayer.position = (currentPlayer.position + rolls) mod 10
    currentPlayer.score += currentPlayer.position + 1

  let
    loser = currentPlayer.nextPlayer(one, two)
    rollCount = roll().rollCount - 1

  loser.score * rollCount



tests:
  # die tests
  roll().value == 1
  roll().value == 2
  roll().value == 3
  roll().rollCount == 4
  block:
    for i in 1..100:
      discard roll()
    let (roll, rollCount) = roll()
    roll == 5 and rollCount == 105

  # final output
  solve(readFile("test.txt")) == 739785
  solve(readFile("input.txt")) == 671580
