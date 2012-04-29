
tag = (id) -> document.getElementById id

keymap = ''
available_chars = 'abcdefghijjklmnopqrstuvwxyz'
available_chars+= 'ABCDEFGHIJJKLMNOPQRSTUVWXYZ'
available_chars+= '1234567890!@#$%^&*()'
available_chars+= '~`_-+-[]{}\\|:;"\',.<>/?'
add_inputs = available_chars.split ''

draw = (arr) ->
  str = ''
  for item in arr
    console.log item
    if typeof item is 'object'
      str+= draw item
    else
      str+= "<span>#{item}</span>"
  "<div>#{str}</div>"

window.onload = ->
  box = tag 'box'
  nothing = tag 'nothing'

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

store = [1, 2, [[1,[3, 4, 5],3], 3, [2,3,4]]]
point = [0]
input = (char) ->
  store.push char
enter = ->
  ''
space = ->
  ''
cancel = ->
  ''
blank = ->
  ''