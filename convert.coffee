
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

cursor = '\t'
render_cursor = '<nav>&nbsp;</nav>'
draw = (arr) ->
  str = ''
  for item in arr
    if Array.isArray item
      str+= draw item
    else if item is cursor
      str+= render_cursor
    else
      item = item.replace(cursor, render_cursor)
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
  recursion = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item
        copy.push (recursion item)
      else if item is cursor then copy.push "#{char}#{cursor}"
      else
        coll = ''
        for c in item
          coll+= char if c is cursor
          coll+= c
        copy.push coll
    copy
  store = recursion store

cancel = ->
  console.log 'called to cancel'
  if store[0] is cursor
    return 'nothing to do'
  recursion = (arr) ->
    if cursor in arr
      return cursor if arr[0] is cursor
      cursor_place = arr.indexOf cursor
      arr = arr[...cursor_place-1].concat arr[cursor_place..]
      return arr
    copy = []
    for item in arr
      if Array.isArray item
        copy.push (recursion item)
      else
        return cursor if item[0] is cursor
        coll = ''
        for c in item
          if c is cursor then coll = coll[...-1]
          coll+= c
        copy.push coll
    copy
  store = recursion store

space = ->
  recursion = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item then copy.push (recursion item)
      else 
        cursor_place = item.indexOf cursor
        if cursor_place is -1 then copy.push item
        else 
          copy.push item.replace(cursor, '')
          copy.push cursor
    copy
  store = recursion store

enter = ->
  recursion = (arr) ->
    if cursor in arr
      return arr.map (x) ->
        if x is cursor then [x] else x
    copy = []
    for item in arr
      if Array.isArray item then copy.push (recursion item)
      else 
        cursor_place = item.indexOf cursor
        if cursor_place is -1 then copy.push item
        else 
          copy.push item.replace(cursor, '')
          copy.push [cursor]
    copy
  store = recursion store

blank = ->
  input ' '

esc = ->
  if cursor in store
    return 'top level.. dont do enything'
  recursion = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item
        if cursor in item
          copy.push item.filter (x) -> x isnt cursor
          copy.push cursor
        else copy.push (recursion item)
      else
        cursor_place = item.indexOf cursor
        if cursor_place is -1 then copy.push item
        else 
          copy.push item.replace(cursor, '')
          copy.push cursor
    copy
  store = recursion store

home = ->
  if store[0]? and store[0] is cursor
    return 'top level, nothing to do'
  recursion = (arr) ->
    if cursor in arr and (arr[0] isnt cursor)
      return [cursor].concat arr.filter (x) -> x isnt cursor
    copy = []
    for item in arr
      if item[0] is cursor then copy.push cursor, item[1..]
      else
        if Array.isArray item then copy.push (recursion item)
        else 
          find_cursor = item.match (new RegExp cursor)
          if find_cursor?
            copy.push "#{cursor}#{item.replace(cursor, '')}"
          else copy.push item
    copy
  store = recursion store

reverse = (arr) ->
  copy = []
  for item in arr.reverse()
    if Array.isArray item then copy.push (reverse item)
    else 
      coll = ''
      coll+= c for c in item.split('').reverse()
      copy.push coll
  copy

end = ->
  store = reverse store
  do home
  store = reverse store

remove  = ->
  if cursor in store
    store = [cursor]
    return 'done'
  recursion = (arr) ->
    arr.map (x) ->
      if Array.isArray x
        return if cursor in x then cursor else (recursion x)
      else
        if x.match(new RegExp cursor)? then cursor else x
  store = recursion store

left = ->
  if store[0] is cursor then return 'ok'
  recursion = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item
        if item[0] is cursor then copy.push cursor, item[1..]
        else copy.push (recursion item)
      else if item is cursor
        console.log 'copy: ', copy
        last_item = copy.pop()
        if Array.isArray last_item
          last_item = last_item.push cursor
          copy.push last_item
        else copy.push "#{last_item}#{cursor}"
      else
        console.log 'all strings', item
        if item[0] is cursor then copy.push cursor, item[1..]
        else
          find_cursor = item.match (new RegExp cursor)
          console.log 'find? ', find_cursor
          unless find_cursor? then copy.push item
          else 
            console.log 'item to swap: ', item
            swapit = new RegExp "(.)#{cursor}"
            copy.push item.replace(swapit, "#{cursor}$1")
    copy
  store = recursion store

right = ->
  store = reverse store
  do left
  store = reverse store
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
  '46': remove