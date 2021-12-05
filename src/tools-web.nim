import std/strformat
import std/deques
import std/json
import std/sugar
import dom
import utils

proc processSingleUiUpdate*(element: Element, json: JsonNode) =
  let
    text = json{"text"}
    imgSrc = json{"image"}
    size = json{"size"}
    bg = json{"bg"}
    position = json{"position"}
    rotation = json{"rotation"}

  # set text content?
  if text != nil:
    if element.hasChildNodes:
      element.removeChild(element[0])
    let textNode = document.createTextNode(text.getStr |> cstring)
    element.appendChild(textNode)

  # set image source?
  if imgSrc != nil:
    element.setAttribute("src", imgSrc.getStr |> cstring)

  # set bg color?
  if bg != nil:
    element.style.backgroundColor = bg.getStr |> cstring

  # set size of element?
  if size != nil:
    let
      width = size["width"].getInt
      height = size["height"].getInt
    element.style.width = fmt"{width}px" |> cstring
    element.style.height = fmt"{height}px" |> cstring

  # set position of element?
  if position != nil:
    let
      x = position["x"].getInt
      y = position["y"].getInt
    element.style.position = "absolute"
    element.style.left = fmt"{x}px" |> cstring
    element.style.top = fmt"{y}px" |> cstring

  # set rotation of element?
  if rotation != nil:
    let angle = rotation.getInt
    element.style.transform = fmt"rotate({angle}deg)" |> cstring



var
  container* = document.getElementById("container")
  updates* = Deque[JsonNode]()
  animationFrequency* = 5

proc guiAddElement*(lazy: () -> JsonNode) =
  let
    json = lazy()
    id = json["id"].getStr |> cstring
    tag = json["tag"].getStr |> cstring
    child = document.createElement(tag)

  child.id = id
  container.appendChild(child)

  if json.len > 2:
    processSingleUiUpdate(child, json)

proc guiUpdateElement*(lazy: () -> JsonNode) =
  updates.addLast(lazy())

proc guiResource*(fileName: string): string =
  fmt"../../../resources/{fileName}"
