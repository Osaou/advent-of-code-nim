import std/strformat



type
  Matrix*[T] = object
    data*: seq[T]
    rows*, cols*: int
    lastRow*, lastCol*: int

func matrix*[T](rows,cols: int): Matrix[T]
func matrix*[T](rows,cols: int, val: T): Matrix[T]
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

func matrix*[T](rows,cols: int): Matrix[T] =
  Matrix[T](
    data: newSeq[T](rows * cols),
    rows: rows,
    cols: cols,
    lastRow: rows - 1,
    lastCol: cols - 1
  )

func matrix*[T](rows,cols: int, val: T): Matrix[T] =
  result = Matrix[T](
    data: newSeq[T](rows * cols),
    rows: rows,
    cols: cols,
    lastRow: rows - 1,
    lastCol: cols - 1
  )
  for i in 0 .. result.lastRow:
    for j in 0 .. result.lastCol:
      result[i,j] = val

func matrix*[T](source: seq[seq[T]]): Matrix[T] =
  let
    rows = source.len
    cols = source[0].len
  result = Matrix[T](
    data: newSeq[T](rows * cols),
    rows: rows,
    cols: cols,
    lastRow: rows - 1,
    lastCol: cols - 1
  )
  for i in 0 .. result.lastRow:
    for j in 0 .. result.lastCol:
      result[i,j] = source[i][j]

func identity*[T](size: int): Matrix[T] =
  result = Matrix[T](
    data: newSeq[T](size * size),
    rows: size,
    cols: size,
    lastRow: size - 1,
    lastCol: size - 1
  )
  for i in 0 ..< size:
    result[i,i] = 1



# to string

func `$`*[T](matrix: Matrix[T]): string =
  result = fmt"matrix({matrix.rows}, {matrix.cols}):"
  result &= "\n["

  for i in 0 .. matrix.lastRow:
    if i > 0:
      result &= " "

    for j in 0 .. matrix.lastCol:
      result &= $matrix[i,j]
      if j < matrix.lastCol:
        result &= ","

    if i == matrix.lastRow:
      result &= "]"
    result &= "\n"



# indexing

func `[]`*[T](matrix: Matrix[T], i,j: int): T =
  assert 0 <= i and i <= matrix.lastRow
  assert 0 <= j and j <= matrix.lastCol
  matrix.data[i * matrix.cols + j]

proc `[]=`*[T](matrix: var Matrix[T], i,j: int, value: T) =
  assert 0 <= i and i <= matrix.lastRow
  assert 0 <= j and j <= matrix.lastCol
  matrix.data[i * matrix.cols + j] = value



# basic algebraic functions

func add*[T](source: Matrix[T], scalar: int): Matrix[T] =
  result = matrix[T](source.rows, source.cols)
  for i in 0 .. source.lastRow:
    for j in 0 .. source.lastCol:
      result[i,j] = source[i,j] + scalar

func add*[T](a, b: Matrix[T]): Matrix[T] =
  assert a.rows == b.rows and a.cols == b.cols
  result = matrix[T](a.rows, a.cols)
  for i in 0 .. a.lastRow:
    for j in 0 .. a.lastCol:
      result[i,j] = a[i,j] + b[i,j]



func mul*[T](source: Matrix[T], scalar: int): Matrix[T] =
  result = matrix[T](source.rows, source.cols)
  for i in 0 .. source.lastRow:
    for j in 0 .. source.lastCol:
      result[i,j] = source[i,j] * scalar

func mul*[T](a, b: Matrix[T]): Matrix[T] =
  assert a.cols == b.rows
  result = matrix[T](a.rows, b.cols)

  for i in 0 .. a.lastRow:
    for j in 0 .. b.lastCol:

      var dot = 0
      for k in 0 .. a.lastCol:
        dot += a[i,k] * b[k,j]
      result[i,j] = dot



func transpose*[T](source: Matrix[T]): Matrix[T] =
  result = matrix[T](source.cols, source.rows)
  for i in 0 .. source.lastRow:
    for j in 0 .. source.lastCol:
      result[j,i] = source[i,j]

func clamp*[T](source: Matrix[T], max: T): Matrix[T] =
  result = matrix[T](source.rows, source.cols)
  for i in 0 .. source.lastRow:
    for j in 0 .. source.lastCol:
      result[i,j] = min(source[i,j], max)



# flipping

func flipH*[T](source: Matrix[T]): Matrix[T] =
  result = matrix[T](source.rows, source.cols)
  for i in 0 .. source.lastRow:
    for j in 0 .. source.lastCol:
      result[i, source.lastCol - j] = source[i,j]

func flipV*[T](source: Matrix[T]): Matrix[T] =
  result = matrix[T](source.rows, source.cols)
  for i in 0 .. source.lastRow:
    for j in 0 .. source.lastCol:
      result[source.lastRow - i, j] = source[i,j]



# splitting

func splitH*[T](source: Matrix[T], column: int): tuple[left: Matrix[T], right: Matrix[T]] =
  assert 0 <= column and column <= source.lastCol

  var left = matrix[T](source.rows, column)
  for i in 0 .. source.lastRow:
    for j in 0 ..< column:
      left[i,j] = source[i,j]

  let c = column + 1

  var right = matrix[T](source.rows, source.cols - c)
  for i in 0 .. source.lastRow:
    for j in 0 ..< source.lastCol - column:
      right[i,j] = source[i, j + c]

  (left:left, right:right)

func splitV*[T](source: Matrix[T], row: int): tuple[top: Matrix[T], bottom: Matrix[T]] =
  assert 0 <= row and row <= source.lastRow

  var top = matrix[T](row, source.cols)
  for i in 0 ..< row:
    for j in 0 .. source.lastCol:
      top[i,j] = source[i,j]

  let r = row + 1

  var bottom = matrix[T](source.rows - r, source.cols)
  for i in 0 ..< source.lastRow - row:
    for j in 0 .. source.lastCol:
      bottom[i,j] = source[i + r, j]

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
  assert m.rows == 5
  assert m.lastRow == 4
  assert m.cols == 3
  assert m.lastCol == 2
  assert m2.cols == 3
  assert m2.rows == 3

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
