
tag = (id) -> document.getElementById id

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
    if typeof item is 'object'
      str+= draw item
    else
      item = item.replace curse, render_curse
      str+= "<span>#{item}</span>"
  "<div>#{str}</div>"

control =
  '8':  cancel
  '13': enter
  '32': space
  '9':  tab
  '27': esc
  '37': left
  '39': right
  '38': up
  '40': down

window.onload = ->
  box = tag 'box'
  nothing = tag 'nothing'
  nothing.focus()

  do refresh = ->
    box.innerHTML = draw store

  nothing.onkeypress = (e) ->
    char = String.fromCharCode e.keyCode
    if char in add_inputs
      console.log "(#{char}) in inputs"
      input char
      do refresh
    return false
  nothing.onkeydown = (e) ->
    code = e.keyCode
    if control[String code]?
      do control(String code)

store = ['45345', '345345', ['444\t']]

input = (char) ->
  reverse = (arr) ->
    copy = []
    for item in arr
      if typeof item is 'object'
        copy.push reverse item
      else
        coll = ''
        for c in item
          if c is curse
            coll+= char
          coll+= c
        copy.push coll
    return copy
  store = reverse store
cancel = ->
  ''
enter = ->
  ''
space = ->
  ''
blank = ->
  ''
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
tab = ->
  ''