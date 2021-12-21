import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import memo
import utils



type
  Player = object
    position: int
    score: int

  GameState = tuple
    current: Player
    next: Player

  GameResult = tuple
    a, b: int64

  DiracDice = tuple
    d1, d2, d3: int

proc diracDie(): array[3*3*3, DiracDice] =
  var i = 0
  for a in 1..3:
    for b in 1..3:
      for c in 1..3:
        result[i] = (d1:a, d2:b, d3:c)
        i += 1

proc gameRound(state: GameState): GameResult {.memoized.} =
  if state.current.score >= 21:
    return (a:1'i64, b:0'i64)
  elif state.next.score >= 21:
    return (a:0'i64, b:1'i64)

  var score = (a:0'i64, b:0'i64)

  for (d1,d2,d3) in diracDie():
    var current = state.current
    current.position = (current.position + d1+d2+d3) mod 10
    current.score += current.position + 1

    let (b, a) = gameRound(( current:state.next, next:current ))
    score = (
      a: score.a + a,
      b: score.b + b,
    )

  score



proc solve*(input: string): int64 =
  [@s1, @s2] := input
    .replace("Player 1 starting position: ", "")
    .replace("Player 2 starting position: ", "")
    .splitLines()
    .map(parseInt)

  let
    one = Player(position:s1-1, score:0)
    two = Player(position:s2-1, score:0)
    (a, b) = gameRound(( current:one, next:two ))

  max(a, b)



tests:
  # dice possibilities
  block:
    for (d1,d2,d3) in diracDie():
      echo fmt"{d1}, {d2}, {d3}"
    diracDie().toSeq().len == 27

  # final output
  solve(readFile("test.txt")) == 444_356_092_776_315'i64
  solve(readFile("input.txt")) == 912_857_726_749_764'i64
