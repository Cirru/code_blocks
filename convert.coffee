
tag = (id) -> document.getElementById id
ll = (v...) ->
  for item in v
    time = new Date().getTime()
    console.log time, item

keymap = ''
available_chars = 'abcdefghijjklmnopqrstuvwxyz'
available_chars+= 'ABCDEFGHIJJKLMNOPQRSTUVWXYZ'
available_chars+= '1234567890!@#$%^&*()'
available_chars+= '~`_-+-[]{}\\|:;"\',.<>/?'
add_inputs = available_chars.split ''

curse = '\t'
render_curse = '<nav>&nbsp;</nav>'
draw = (arr) ->
  str = ''
  for item in arr
    if Array.isArray item
      str+= draw item
    else if item is curse
      str+= render_curse
    else
      item = item.replace(curse, render_curse)
        .replace(/\s/g, '&nbsp;')
      str+= "<code>#{item}</code>"
  "<div>#{str}</div>"

window.onload = ->
  box = tag 'box'
  window.focus()

  do refresh = ->
    box.innerHTML = draw store
    console.log 'Refreshing :::: ', store

  document.onkeypress = (e) ->
    char = String.fromCharCode e.keyCode
    if char in add_inputs
      console.log "(#{char}) in inputs"
      input char
      do refresh
    return false
  document.onkeydown = (e) ->
    code = e.keyCode
    if control[''+code]?
      do control[''+code]
      do refresh
      return false

store = ['45345', '345345', ['44', '5', 'sdfsdfsdf\t', ['444']]]

input = (char) ->
  recurse = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item
        copy.push (recurse item)
      else if item is curse then copy.push "#{char}#{curse}"
      else
        coll = ''
        for c in item
          coll+= char if c is curse
          coll+= c
        copy.push coll
    copy
  store = recurse store

cancel = ->
  console.log 'called to cancel'
  if store[0] is curse
    return 'nothing to do'
  recurse = (arr) ->
    if curse in arr
      return curse if arr[0] is curse
      curse_place = arr.indexOf curse
      arr = arr[...curse_place-1].concat arr[curse_place..]
      return arr
    copy = []
    for item in arr
      if Array.isArray item
        copy.push (recurse item)
      else
        return curse if item[0] is curse
        coll = ''
        for c in item
          if c is curse then coll = coll[...-1]
          coll+= c
        copy.push coll
    copy
  store = recurse store

space = ->
  recurse = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item then copy.push (recurse item)
      else 
        curse_place = item.indexOf curse
        if curse_place is -1 then copy.push item
        else 
          copy.push (item[...curse_place].concat item[curse_place+1..])
          copy.push curse
    copy
  store = recurse store

enter = ->
  recurse = (arr) ->
    if curse in arr
      return arr.map (x) ->
        if x is curse then [x] else x
    copy = []
    for item in arr
      if Array.isArray item then copy.push (recurse item)
      else 
        curse_place = item.indexOf curse
        if curse_place is -1 then copy.push item
        else 
          copy.push (item[...curse_place].concat item[curse_place+1..])
          copy.push [curse]
    copy
  store = recurse store

blank = ->
  input ' '
  
esc = ->
  ''
left = ->
  ''
right = ->
  ''
up = ->
  ''
down = ->
  ''

control =
  '8':  cancel
  '13': enter
  '32': space
  '9':  blank
  '27': esc
  '37': left
  '39': right
  '38': up
  '40': down