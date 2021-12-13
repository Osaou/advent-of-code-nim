import std/strformat



type
  Matrix*[T] = object
    data*: seq[T]
    N*, M*: int
    maxN*, maxM*: int

func matrix*[T](N,M: int): Matrix[T]
func matrix*[T](source: seq[seq[T]]): Matrix[T]
func identity*[T](size: int): Matrix[T]
func `$`*[T](matrix: Matrix[T]): string
func `[]`*[T](matrix: Matrix[T], i,j: int): T
proc `[]=`*[T](matrix: var Matrix[T], i,j: int, value: T)
func add*[T](source: Matrix[T], scalar: int): Matrix[T]
func mul*[T](source: Matrix[T], scalar: int): Matrix[T]
func add*[T](a, b: Matrix[T]): Matrix[T]
func mul*[T](a, b: Matrix[T]): Matrix[T]
func transpose*[T](source: Matrix[T]): Matrix[T]
func clamp*[T](source: Matrix[T], max: T): Matrix[T]
func flipH*[T](source: Matrix[T]): Matrix[T]
func flipV*[T](source: Matrix[T]): Matrix[T]
func splitH*[T](source: Matrix[T], column: int): tuple[left: Matrix[T], right: Matrix[T]]
func splitV*[T](source: Matrix[T], row: int): tuple[top: Matrix[T], bottom: Matrix[T]]



# constructors

func matrix*[T](N,M: int): Matrix[T] =
  Matrix[T](
    data: newSeq[T](N * M),
    N: N,
    M: M,
    maxN: N - 1,
    maxM: M - 1
  )

func matrix*[T](source: seq[seq[T]]): Matrix[T] =
  let
    N = source.len
    M = source[0].len
  result = Matrix[T](
    data: newSeq[T](N * M),
    N: N,
    M: M,
    maxN: N - 1,
    maxM: M - 1
  )
  for i in 0 .. result.maxN:
    for j in 0 .. result.maxM:
      result[i, j] = source[i][j]

func identity*[T](size: int): Matrix[T] =
  result = Matrix[T](
    data: newSeq[T](size * size),
    N: size,
    M: size,
    maxN: size - 1,
    maxM: size - 1
  )
  for i in 0 ..< size:
    result[i, i] = 1



# to string

func `$`*[T](matrix: Matrix[T]): string =
  result = fmt"matrix({matrix.N}, {matrix.M}):"

  for i in 0 .. matrix.maxN:
    result &= "\n"
    for j in 0 .. matrix.maxM:
      if matrix[i, j] == 0:
        result &= "."
      else:
        result &= "#"



# indexing

func `[]`*[T](matrix: Matrix[T], i,j: int): T =
  assert 0 <= i and i <= matrix.maxN
  assert 0 <= j and j <= matrix.maxM
  matrix.data[i * matrix.M + j]

proc `[]=`*[T](matrix: var Matrix[T], i,j: int, value: T) =
  assert 0 <= i and i <= matrix.maxN
  assert 0 <= j and j <= matrix.maxM
  matrix.data[i * matrix.M + j] = value



# basic algebraic functions

func add*[T](source: Matrix[T], scalar: int): Matrix[T] =
  result = matrix[T](source.N, source.M)
  for i in 0 .. source.maxN:
    for j in 0 .. source.maxM:
      result[i, j] = source[i, j] + scalar

func mul*[T](source: Matrix[T], scalar: int): Matrix[T] =
  result = matrix[T](source.N, source.M)
  for i in 0 .. source.maxN:
    for j in 0 .. source.maxM:
      result[i, j] = source[i, j] * scalar

func add*[T](a, b: Matrix[T]): Matrix[T] =
  assert a.N == b.N and a.M == b.M
  result = matrix[T](a.N, a.M)
  for i in 0 .. a.maxN:
    for j in 0 .. a.maxM:
      result[i, j] = a[i, j] + b[i, j]

func mul*[T](a, b: Matrix[T]): Matrix[T] =
  assert a.N == b.N and a.M == b.M
  result = matrix[T](a.N, a.M)
  for i in 0 .. a.maxN:
    for j in 0 .. a.maxM:
      result[i, j] = a[i, j] * b[i, j]

func transpose*[T](source: Matrix[T]): Matrix[T] =
  result = matrix[T](source.M, source.N)
  for i in 0 .. source.maxN:
    for j in 0 .. source.maxM:
      result[j, i] = source[i, j]

func clamp*[T](source: Matrix[T], max: T): Matrix[T] =
  result = matrix[T](source.N, source.M)
  for i in 0 .. source.maxN:
    for j in 0 .. source.maxM:
      result[i, j] = min(source[i, j], max)



# flipping

func flipH*[T](source: Matrix[T]): Matrix[T] =
  result = matrix[T](source.N, source.M)
  for i in 0 .. source.maxN:
    for j in 0 .. source.maxM:
      result[i, source.maxM - j] = source[i, j]

func flipV*[T](source: Matrix[T]): Matrix[T] =
  result = matrix[T](source.N, source.M)
  for i in 0 .. source.maxN:
    for j in 0 .. source.maxM:
      result[source.maxN - i, j] = source[i, j]



# splitting

func splitH*[T](source: Matrix[T], column: int): tuple[left: Matrix[T], right: Matrix[T]] =
  assert 0 <= column and column <= source.maxM

  var left = matrix[T](source.N, column)
  for i in 0 .. source.maxN:
    for j in 0 ..< column:
      left[i, j] = source[i, j]

  let c = column + 1

  var right = matrix[T](source.N, source.M - c)
  for i in 0 .. source.maxN:
    for j in 0 ..< source.maxM - column:
      right[i, j] = source[i, j + c]

  (left:left, right:right)

func splitV*[T](source: Matrix[T], row: int): tuple[top: Matrix[T], bottom: Matrix[T]] =
  assert 0 <= row and row <= source.maxN

  var top = matrix[T](row, source.M)
  for i in 0 ..< row:
    for j in 0 .. source.maxM:
      top[i, j] = source[i, j]

  let r = row + 1

  var bottom = matrix[T](source.N - r, source.M)
  for i in 0 ..< source.maxN - row:
    for j in 0 .. source.maxM:
      bottom[i, j] = source[i + r, j]

  (top:top, bottom:bottom)



# tests

when isMainModule:
  let m = matrix(@[
    @[1, 10, 100],
    @[2, 20, 200],
    @[3, 30, 300],
    @[4, 40, 400],
    @[5, 50, 500],
  ])
  var m2 = matrix[int](3, 3)
  let m3 = identity[int](3)

  # size
  assert m.N == 5
  assert m.maxN == 4
  assert m.M == 3
  assert m.maxM == 2
  assert m2.M == 3
  assert m2.N == 3

  # assignment
  m2[0,0] = 3
  m2[1,1] = 9

  # indexing
  assert m2[0,0] == 3
  assert m2[1,1] == 9
  assert m[0,2] == 100
  assert m[2,0] == 3

  # addition
  assert m2.add(m3) == matrix(@[
    @[4, 0,  0],
    @[0, 10, 0],
    @[0, 0,  1],
  ])
  assert m3.add(5) == matrix(@[
    @[6, 5, 5],
    @[5, 6, 5],
    @[5, 5, 6],
  ])

  # multiplication
  assert m2.mul(m3) == matrix(@[
    @[3, 0, 0],
    @[0, 9, 0],
    @[0, 0, 0],
  ])
  assert m3.mul(5) == matrix(@[
    @[5, 0, 0],
    @[0, 5, 0],
    @[0, 0, 5],
  ])

  # transposing
  assert m.transpose() == matrix(@[
    @[1,   2,   3,   4,   5],
    @[10,  20,  30,  40,  50],
    @[100, 200, 300, 400, 500],
  ])

  # flipping
  assert m.flipV() == matrix(@[
    @[5, 50, 500],
    @[4, 40, 400],
    @[3, 30, 300],
    @[2, 20, 200],
    @[1, 10, 100],
  ])
  assert m.flipH() == matrix(@[
    @[100, 10, 1],
    @[200, 20, 2],
    @[300, 30, 3],
    @[400, 40, 4],
    @[500, 50, 5],
  ])

  # splitting horisontally
  let (left, right) = m.splitH(1)
  assert left == matrix(@[
    @[1],
    @[2],
    @[3],
    @[4],
    @[5],
  ])
  assert right == matrix(@[
    @[100],
    @[200],
    @[300],
    @[400],
    @[500],
  ])

  # splitting vertically
  let (top, bottom) = m.splitV(1)
  assert top == matrix(@[
    @[1, 10, 100],
  ])
  assert bottom == matrix(@[
    @[3, 30, 300],
    @[4, 40, 400],
    @[5, 50, 500],
  ])
