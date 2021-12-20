import std/[strutils, strformat, macros]



#[
let
  a = fromBin[int]( @[1,0,0,1,0].join() )
  b = @[1,0,0,1,0].join() |> fromBin[int]()

assert a == b
]#
macro `|>`*(lhs, rhs: untyped): untyped =
  case rhs.kind:
  of nnkIdent: # single-parameter functions
    result = newCall(rhs, lhs)
  else:
    result = rhs
    result.insert(1, lhs)



#[
let
  a = @[@[ 0, 1, 2, 3,  4 ],
        @[ 5, 6, 7, 8,  9 ],
        @[ 1, 0, 0, 0, 42 ]]

  b = transpose(a)

assert b == @[@[ 0, 5,  1 ],
              @[ 1, 6,  0 ],
              @[ 2, 7,  0 ],
              @[ 3, 8,  0 ],
              @[ 4, 9, 42 ]]
]#
proc transposeMatrix*[T](s: seq[seq[T]]): seq[seq[T]] =
  result = newSeq[seq[T]](s[0].len)
  for i in 0 .. s[0].high:
    result[i] = newSeq[T](s.len)
    for j in 0 .. s.high:
      result[i][j] = s[j][i]



#[
let
  a = @[@[ 0, 1,    2, 3,  4 ],
        @[ 5, 6, @[ 7, 8,  9 ], ],
        @[ 1, 0,    0, 0, 42 ]]

  b = flatten(a)

assert b == @[ 0, 1, 2, 3,  4,
               5, 6, 7, 8,  9,
               1, 0, 0, 0, 42 ]
]#
proc flatten*[T](s: seq[T]): seq[T] =
  result = newSeq[T]()
  for x in s:
    if x of seq:
      result &= flatten(x)
    else:
      result &= x



func isInt*(c: char): bool =
  c.int >= 48 and
  c.int <= 57

func charToInt*(c: char): int =
  c.int - 48



func parseGrid*[T: SomeInteger](input: string): seq[seq[T]] =
  for line in input.splitLines():
    var row = newSeq[T]()
    for c in line:
      row &= c.charToInt()

    result &= row



func skip*[T](s: openArray[T], count: int): seq[T] =
  doAssert 0 <= count and count < s.len
  s[count ..< s.len]



macro debug*(args: varargs[untyped]): untyped =
  result = nnkStmtList.newTree()
  for n in args:
    result.add newCall("write", newIdentNode("stdout"), newLit(n.repr))
    result.add newCall("write", newIdentNode("stdout"), newLit(": "))
    result.add newCall("writeLine", newIdentNode("stdout"), n)



macro tests*(body: untyped): untyped =
  var procBody = newStmtList()
  for n in body:
    procBody.add newCall("write", newIdentNode("stdout"), newLit(fmt"TEST: "))
    procBody.add newCall("write", newIdentNode("stdout"), newLit(n.repr))
    procBody.add newIfStmt(
      (n, newCall("writeLine", newIdentNode("stdout"), newLit(" ✅")))
    ).add(newNimNode(nnkElse).add(
      newCall("writeLine", newIdentNode("stdout"), newLit(" ⛔"))
    ))

  template procDecl(code): untyped =
    proc tests*() =
      code

  result = getAst(procDecl(procBody))
