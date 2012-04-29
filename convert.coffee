
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
    console.log 'keyCode .... ', code
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
          copy.push item.replace(curse, '')
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
          copy.push item.replace(curse, '')
          copy.push [curse]
    copy
  store = recurse store

blank = ->
  input ' '

esc = ->
  if curse in store
    return 'top level.. dont do enything'
  recurse = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item
        if curse in item
          copy.push item.filter (x) -> x isnt curse
          copy.push curse
        else copy.push (recurse item)
      else
        curse_place = item.indexOf curse
        if curse_place is -1 then copy.push item
        else 
          copy.push item.replace(curse, '')
          copy.push curse
    copy
  store = recurse store

home = ->
  if store[0]? and store[0] is curse
    return 'top level, nothing to do'
  recurse = (arr) ->
    if curse in arr and (arr[0] isnt curse)
      return [curse].concat arr.filter (x) -> x isnt curse
    copy = []
    for item in arr
      if item[0] is curse then copy.push curse, item[1..]
      else
        if Array.isArray item then copy.push (recurse item)
        else 
          find_curse = item.match (new RegExp curse)
          if find_curse?
            copy.push "#{curse}#{item.replace(curse, '')}"
          else copy.push item
    copy
  ll store
  store = recurse store

end = ->
  reverse = (arr) ->
    copy = []
    for item in arr.reverse()
      if Array.isArray item then copy.push (reverse item)
      else 
        coll = ''
        coll+= c for c in item.split('').reverse()
        copy.push coll
    copy
  store = reverse store
  do home
  store = reverse store

remove  = -> ''

left = ->
  ''
right = ->
  ''
up = ->
  ''
down = ->
  ''
### beyond demo on this page
save = -> ''
import = -> ''
export = -> ''
###

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
  '36': home
  '35': end