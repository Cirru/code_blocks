
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
    console.log code
    switch code
      when 8
        console.log 'cancel'
        do cancel
        do refresh
        false
      when 13
        console.log 'enter'
        do enter
        do refresh
        false
      when 32
        console.log 'space'
        do space
        do refresh
        false
      when 9
        console.log 'tab'
        do blank
        do refresh
        false
      when 27
        console.log 'esc'
        do esc
        do refresh
        false

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