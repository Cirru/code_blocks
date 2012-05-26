
tag = (id) -> document.getElementById id
new_footer = -> document.createElement 'footer'
ll = (v...) ->
  for item in v
    time = new Date().getTime()
    console.log time, item

socket = io.connect 'http://localhost:8000' if io?

keymap = ''
valid_chars = 'abcdefghijjklmnopqrstuvwxyz' +
  'ABCDEFGHIJJKLMNOPQRSTUVWXYZ' +
  '1234567890!@#$%^&*()' +
  '~`_-+=-[]{}\\|:;"\',.<>/?'
add_inputs = valid_chars.split ''

cursor = '\t'
cur_ = '<nav>&nbsp;</nav>'
draw = (arr, can_fold=yes) ->
  surr = no if arr.toString().length > 50
  surr = no if arr.map((x)->
    if Array.isArray x then 1 else 0).reduce((x,y) ->
      x + y) > 2
  str = ''
  for item in arr
    if Array.isArray item then str+= draw item, surr else
      item = item.replace(cursor, cur_)
        .replace(/\s/g, '&nbsp;')
      str+= "<code>#{item}</code>"
  inline = ''
  if can_fold
    if (arr.every (x) -> typeof x is 'string')
      if arr.join('').length < 30
        inline = ' class="inline"'
  "<div#{inline}>#{str}</div>"

editor_mode = on
store = ['\t']
history = [store]
current = 0

skip = 'skip'
stay = 'stay'

history_maker = ->
  history = history[..current]
  history.push store.concat()
  current+= 1
  socket.emit 'sync', store if socket?

window.onload = ->
  box = tag 'box'
  window.focus()
  do refresh = ->
    box.innerHTML = draw store

  if io? then socket.on 'new', (data) ->
    store = data
    do refresh

  document.onkeypress = (e) ->
    unless editor_mode then return 'locked'
    char = String.fromCharCode e.keyCode
    unless e.ctrlKey or e.altKey
      if char in add_inputs
        input char
        do refresh
        do history_maker
      false

  document.onkeydown = (e) ->
    code = e.keyCode
    console.log code, editor_mode
    unless editor_mode
      unless code is 27 then 'locked'
    unless e.ctrlKey or e.altKey
      if control[''+code]?
        send_back = do control[''+code]
        unless send_back is stay
          do refresh
          do history_maker
        false
    else if e.ctrlKey and (not e.altKey)
      if control['c_'+code]?
        send_back = do control['c_'+code]
        unless send_back is stay
          do refresh
          do history_maker
        false

input_R = (arr, char) ->
  copy = []
  for item in arr
    copy.push(
      if Array.isArray item then input_R item, char
      else item.replace cursor, "#{char}#{cursor}")
  copy
input = (char) -> store = input_R store, char

cancel_R = (arr) ->
  point = arr.indexOf cursor
  if point >= 0
    if point is 0 then cursor else
      arr.splice point-1, 1
      arr
  else
    copy = []
    for item in arr
      if Array.isArray item then copy.push (cancel_R item) else
        point = item.indexOf cursor
        copy.push(
          if point is -1 then item
          else if point is 0 then cursor
          else "#{item[...point-1]}#{item[point..]}")
    copy
cancel = ->
  if store[0] is cursor then return skip
  store = cancel_R store

space_R = (arr) ->
  if cursor in arr then return arr
  copy = []
  for item in arr
    copy.push.apply copy, (
      if Array.isArray item then [space_R item] else
        if (item.indexOf cursor) is -1 then [item]
        else [(item.replace cursor, ''), cursor])
  copy
space = -> store = space_R store

enter_R = (arr) ->
  if cursor in arr then arr.map (x) ->
      if x is cursor then [x] else x
  else
    copy = []
    for item in arr
      if Array.isArray item then copy.push (enter_R item)
      else
        point = item.indexOf cursor
        copy.push.apply copy, (
          if point is -1 then [item]
          else [(item.replace cursor, ''), [cursor]])
    copy
enter = -> store = enter_R store

blank = -> input ' '

pgup_R = (arr) ->
  copy = []
  for item in arr
    if Array.isArray item
      if item[0] is cursor
        copy.push cursor
        copy.push item[1..] if item.length > 1
      else copy.push (pgup_R item)
    else if item is cursor
      last_item = copy.pop()
      if Array.isArray last_item
        last_item.push cursor
        copy.push last_item
      else copy.push cursor, last_item
    else
      if item.indexOf(cursor) < 0 then copy.push item
      else copy.push cursor, (item.replace cursor, '')
  copy
pgup = ->
  if store[0] is cursor then return 'skip'
  store = pgup_R store

reverse = (arr) ->
  arr.reverse().map (item) ->
    if Array.isArray item then reverse item
    else item.split('').reverse().join ''

reverse_action = (action) ->
  store = reverse store
  do action
  store = reverse store

pgdown = -> reverse_action pgup

home_R = (arr) ->
  if cursor in arr and (arr[0] isnt cursor)
    [cursor].concat arr.filter (x) -> x isnt cursor
  else
    copy = []
    for item in arr
      if item[0] is cursor
        copy.push cursor
        copy.push item[1..] if item.length > 1
      else copy.push(
        if Array.isArray item then home_R item else
          find_cursor = item.match (new RegExp cursor)
          if find_cursor?
            "#{cursor}#{item.replace(cursor, '')}"
          else item)
    copy
home = ->
  if store[0]? and store[0] is cursor then return skip
  store = home_R store

end = -> reverse_action home

remove_R = (arr) -> arr.map (x) ->
  if (x.indexOf cursor) >= 0 then cursor else
    if Array.isArray x then remove_R x else x
remove  = ->
  if cursor in store
    store = [cursor]
    return skip
  store = remove_R store

left_R = (arr) ->
  copy = []
  for item in arr
    if Array.isArray item
      if item[0] is cursor
        copy.push cursor
        copy.push item[1..] if item.length > 1
      else copy.push (left_R item)
    else if item is cursor
      last_item = copy.pop()
      if Array.isArray last_item
        last_item.push cursor
        copy.push last_item
      else copy.push "#{last_item}#{cursor}"
    else
      if item[0] is cursor
        copy.push cursor
        copy.push item[1..] if item.length > 1
      else
        point = item.indexOf cursor
        if point < 0 then copy.push item
        else 
          part_a = "#{item[...point-1]}#{cursor}"
          part_b = "#{item[point-1]}#{item[point+1..]}"
          copy.push "#{part_a}#{part_b}"
  copy
left = ->
  if store[0] is cursor then return skip
  store = left_R store

right = -> reverse_action left

down_R = (arr) ->
  copy = []
  has_cursor = no
  for item in arr
    if item in [cursor, [cursor]] then has_cursor = yes
    else if typeof item is 'string'
      copy.push(
        if item.match(new RegExp cursor)?
          has_cursor = yes
          item.replace cursor, ''
        else item)
    else
      if has_cursor
        item.unshift cursor
        copy.push item
        has_cursor = no
      else
        obj = down_R item
        copy.push obj.value if obj.value.length > 0
        copy.push cursor if obj.has_cursor
  obj =
    value: copy
    has_cursor: has_cursor
down = ->
  for item in store.concat().reverse()
    if Array.isArray item then break
    if  (item.indexOf cursor) >= 0 then return skip
  store = (down_R store).value

up = -> reverse_action down

left_step_R = (arr) ->
  if arr[0] is cursor then return arr
  copy = []
  for item in arr
    if Array.isArray item then copy.push (left_step_R item)
    else if item is cursor
      last_item = copy.pop()
      copy.push cursor, last_item
    else
      if (item.indexOf cursor) is -1 then copy.push item
      else copy.push cursor, item.replace(cursor, '')
  copy
left_step = ->
  store = left_step_R store

right_step = -> reverse_action left_step

snippet = null

copy_recursion = (arr) ->
  for item in arr
    if Array.isArray item
      if cursor in item
        snippet = item.filter (x) -> x isnt cursor
      else copy_recursion item
    else if item.indexOf(cursor) >= 0
      snippet = item.replace cursor, ''
ctrl_copy = ->
  copy_recursion store
  # console.log snippet

cut_recursion = (arr) ->
  console.log arr
  arr.map (item) ->
    if Array.isArray item
      if cursor in item
        snippet = item.filter (x) -> x isnt cursor
        cursor
      else cut_recursion item
    else
      if (item.indexOf cursor) < 0 then item
      else 
        snippet = item.replace cursor, ''
        cursor
ctrl_cut = ->
  if cursor in store then return skip
  store = cut_recursion store

paste_recursion = (arr) ->
  copy = []
  for item in arr
    if Array.isArray item then copy.push (paste_recursion item)
    else if item is cursor then copy.push snippet, cursor
    else if (item.indexOf cursor) < 0 then copy.push item
    else copy.push snippet, item
  copy
ctrl_paste = ->
  store = paste_recursion store if snippet?

version_map =
  store: store
  stemp: '000000 00:00'
  child: [cursor]
  commit: '/'

version_cursor = version_map

pair_num = (num) ->
  if num < 10 then '0'+(String num) else (String num)

stemp = ->
  date_obj = new Date()
  year = (String date_obj.getFullYear())[2..3]
  month = pair_num (date_obj.getMonth() + 1)
  date = pair_num date_obj.getDate()
  hour = pair_num date_obj.getHours()
  minute = pair_num date_obj.getMinutes()
  "#{year}#{month}#{date} #{hour}:#{minute}"

history_reset = ->
  history = [store]
  current = 0

save_version = ->
  version_cursor.child.pop()
  version_cursor.child.push (
    store: store
    stemp: do stemp
    child: []
    commit: prompt('add phrase to commit') or 'Save')
  last_item = version_cursor.child
  version_cursor = version_cursor.child[last_item.length-1]
  version_cursor.child.push cursor
  do history_reset
  'stay'

choose_version = (new_version_cursor) ->
  version_cursor.child.pop()
  version_cursor = new_version_cursor
  store = version_cursor.store
  version_cursor.child.push cursor
  do history_reset
  do view_version

current_version = document.createElement 'header'
current_version.innerHTML = 'current'

view_recursion = (obj) ->
  if obj is cursor then return current_version
  if obj.commit?
    footer = new_footer()
    footer.onclick = (e) ->
      choose_version obj
      e.stopPropagation()
      return false
    footer.innerHTML+= "#{obj.commit}<br>"
    footer.innerHTML+= "<span>#{obj.stemp}</span><br>"
    obj.child.forEach (item) ->
      result = view_recursion item
      # console.log 'result: ', result
      footer.appendChild result
  footer
view_version = ->
  tag('box').innerHTML = ''
  tag('box').appendChild (view_recursion version_map)
  'stay'

esc = ->
  if editor_mode
    do view_version
    editor_mode = off
  else
    (tag 'box').innerHTML = draw store
    editor_mode = on
  'stay'

go_ahead = ->
  if history[current+1]?
    store = history[current+1]
    current+= 1
    (tag 'box').innerHTML = draw store
  'stay'

go_back = ->
  console.log 'current: ', current
  if history[current-1]?
    store = history[current-1]
    current-= 1
    (tag 'box').innerHTML = draw store
  'stay'

source = (arr) ->
  copy = []
  for item in arr
    if item in [cursor, [cursor]] then continue
    else if Array.isArray item then copy.push (source item)
    else if (item.indexOf cursor) is -1 then copy.push item
    else copy.push item.replace(cursor, '')
  copy

output = []
run_code = ->
  output = []
  console.log (source store)
  run item for item in (source store)
  output = output.map (item) ->
    item.replace(/\s/g, '&nbsp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
  .join '<br>'
  console.log 'output', output
  (tag 'box').innerHTML = "<div id='result'>#{output}</div>"
  editor_mode = off
  'stay'

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
  '33': pgup
  '34': pgdown
  'c_37': left_step
  'c_39': right_step
  'c_67': ctrl_copy
  'c_88': ctrl_cut
  'c_80': ctrl_paste
  'c_83': save_version
  'c_90': go_back
  'c_89': go_ahead
  'c_69': run_code
