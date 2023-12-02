import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils
import elvis



type
  Reveal = tuple
    r, g, b: int
  Game = tuple
    id: int
    reveals: seq[Reveal]
    knownAmount: Reveal

func parseGame(row: string): Game
func parseId(input: string): int
func parseGameRound(input: string): seq[Reveal]
func parseReveal(input: string): Reveal
func parseColor(input: string): Reveal



func parseGame(row: string): Game =
  let
    input = row.split(":")
    id    = input[0] |> parseId()
    round = input[1] |> parseGameRound()

  (
    id: id,
    reveals: round,
    knownAmount: round
      .foldl((
        r: if a.r > b.r: a.r else: b.r,
        g: if a.g > b.g: a.g else: b.g,
        b: if a.b > b.b: a.b else: b.b
      ), (
        r: 0,
        g: 0,
        b: 0
      ))
  )

func parseId(input: string): int =
  input
    .replace("Game", "")
    .strip()
    .parseInt()

func parseGameRound(input: string): seq[Reveal] =
  input
    .split(";")
    .mapIt(it.strip())
    .map(parseReveal)

func parseReveal(input: string): Reveal =
  input
    .split(",")
    .mapIt(it.strip())
    .map(parseColor)
    .foldl((r:a.r+b.r, g:a.g+b.g, b:a.b+b.b), (r:0, g:0, b:0))

func parseColor(input: string): Reveal =
  let
    parts = input.split(" ")
    count = parts[0] |> parseInt()
    color = parts[1]

  case color
  of "red":
    return (r:count, g:0, b:0)
  of "green":
    return (r:0, g:count, b:0)
  of "blue":
    return (r:0, g:0, b:count)
  else:
    return (r:0, g:0, b:0)



proc solve*(input: string): int =
  input
    .split("\n")
    .filterIt(it.strip() != "")
    .map(parseGame)
    .foldl(a + (b.knownAmount.r * b.knownAmount.g * b.knownAmount.b), 0)



tests:
  # ids
  parseId("Game 1") == 1
  parseId("Game 1234") == 1234
  # colors
  parseColor("1 red") == (r:1, g:0, b:0)
  parseColor("23 green") == (r:0, g:23, b:0)
  parseColor("456 blue") == (r:0, g:0, b:456)
  # reveals
  parseReveal("1 red, 2 green, 3 blue") == (r:1, g:2, b:3)
  # rounds
  parseGameRound("3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green") == @[
    (r:4, g:0, b:3),
    (r:1, g:2, b:6),
    (r:0, g:2, b:0),
  ]
  # games
  parseGame("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green") == (
    id: 1,
    reveals: @[
      (r:4, g:0, b:3),
      (r:1, g:2, b:6),
      (r:0, g:2, b:0),
    ],
    knownAmount: (r:4, g:2, b:6)
  )
  parseGame("Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue") == (
    id: 2,
    reveals: @[
      (r:0, g:2, b:1),
      (r:1, g:3, b:4),
      (r:0, g:1, b:1),
    ],
    knownAmount: (r:1, g:3, b:4)
  )
  parseGame("Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red") == (
    id: 3,
    reveals: @[
      (r:20, g:8, b:6),
      (r:4, g:13, b:5),
      (r:1, g:5, b:0),
    ],
    knownAmount: (r:20, g:13, b:6)
  )
  # solves
  solve(readFile("test.txt")) == 2286
  solve(readFile("input.txt")) == 58269
