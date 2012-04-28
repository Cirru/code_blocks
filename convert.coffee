
tag = (id) -> document.getElementById id

parse = (arr) ->
  do recurse = ->
    head = do arr.shift
    if head is '('
      in_brackets = []
      in_brackets.push do recurse until arr[0] is ')'
      do arr.shift
      return in_brackets
    else
      return head

draw = (arr) ->
  console.log 'draw'
  str = ''
  console.log 'arr:', arr
  for item in arr
    if (typeof item is 'string')
      str+= "<div class='atom'>#{item}</div>"
    else if (typeof item is 'object')
      console.log 'item', item
      str+= "<div class='exp'>#{draw item}</div>"
  str

window.onload = ->
  textareaEditor 'source'
  source = tag 'source'
  result = tag 'result'

  source.oninput = ->
    return 0 if source.value.length < 4
    arr = "(#{source.value})"
      .replace(/\(/g, ' ( ')
      .replace(/\)/g, ' ) ')
      .split(' ')
      .filter (x) -> x.length > 0
    result.innerHTML = (draw (parse arr))