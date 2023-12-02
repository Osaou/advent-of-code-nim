import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils



type
  Reveal = tuple
    r, g, b: int
  Game = tuple
    id: int
    reveals: seq[Reveal]
    possible: bool

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
    possible: round
      .allIt(it.r <= 12 and it.g <= 13 and it.b <= 14)
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

func parseColor(input: string): Reveal {.raises: [ValueError].} =
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
    .filterIt(it.possible)
    .foldl(a + b.id, 0)



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
    possible: true
  )
  # solves
  solve(readFile("test.txt")) == 8
  solve(readFile("input.txt")) == 2101
