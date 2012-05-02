
tag = (id) -> document.getElementById id
new_footer = -> document.createElement 'footer'
ll = (v...) ->
  for item in v
    time = new Date().getTime()
    console.log time, item

keymap = ''
available_chars = 'abcdefghijjklmnopqrstuvwxyz'
available_chars+= 'ABCDEFGHIJJKLMNOPQRSTUVWXYZ'
available_chars+= '1234567890!@#$%^&*()'
available_chars+= '~`_-+=-[]{}\\|:;"\',.<>/?'
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
        .replace(/\s/g, '<span class="appear">&nbsp;</span>')
      str+= "<code>#{item}</code>"
  inline_block = ''
  if arr.toString().length < 15
    inline_block = ' class="inline_block"'
  "<div#{inline_block}>#{str}</div>"

editor_mode = on
store = ['\t']
history = [store]
current = 0

history_generator = ->
  history = history[..current]
  history.push store
  current+= 1

window.onload = ->
  box = tag 'box'
  window.focus()

  do refresh = ->
    box.innerHTML = draw store
    # console.log 'Refreshing :::: ', store

  document.onkeypress = (e) ->
    unless editor_mode then return 'locked'
    char = String.fromCharCode e.keyCode
    # console.log 'target!', char, e.ctrlKey
    unless e.ctrlKey or e.altKey
      if char in add_inputs
        # console.log "(#{char}) in inputs"
        input char
        do refresh
        do history_generator
      false
  document.onkeydown = (e) ->
    code = e.keyCode
    unless editor_mode
      unless code is 27 then return 'locked'
    # console.log 'keyCode .... ', code, e.ctrlKey
    unless e.ctrlKey or e.altKey
      if control[''+code]?
        send_back = do control[''+code]
        unless send_back is 'stay'
          do refresh
          do history_generator
        return false
    if e.ctrlKey and (not e.altKey)
      if control['c_'+code]?
        send_back = do control['c_'+code]
        unless send_back is 'no need to refresh'
          unless code in [89, 90]
            do refresh
            do history_generator
        false

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
  # console.log 'called to cancel'
  if store[0] is cursor then return 'skip'
  recursion = (arr) ->
    point = arr.indexOf cursor
    unless point is -1
      return arr if point is 0
      arr = arr[...point-1].concat arr[point..]
      return arr
    copy = []
    for item in arr
      if Array.isArray item then copy.push (recursion item)
      else
        point = item.indexOf cursor
        if point is -1 then copy.push item
        else if point is 0 then copy.push cursor
        else copy.push "#{item[...point-1]}#{item[point..]}"
    copy
  store = recursion store

space = ->
  recursion = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item then copy.push (recursion item)
      else 
        if (item.indexOf cursor) is -1 then copy.push item
        else 
          copy.push (item.replace cursor, ''), cursor
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
        point = item.indexOf cursor
        if point is -1 then copy.push item
        else 
          copy.push (item.replace cursor, ''), [cursor]
    copy
  store = recursion store

blank = -> input ' '

pgup = ->
  if store[0] is cursor then return 'skip'
  recursion = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item
        if item[0] is cursor
          copy.push cursor
          copy.push item[1..] if item.length > 1
        else copy.push (recursion item)
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
  store = recursion store

pgdown = ->
  store = reverse store
  do pgup
  store = reverse store

home = ->
  if store[0]? and store[0] is cursor
    return 'nothing to do'
  recursion = (arr) ->
    if cursor in arr and (arr[0] isnt cursor)
      return [cursor].concat arr.filter (x) -> x isnt cursor
    copy = []
    for item in arr
      if item[0] is cursor
        copy.push cursor
        copy.push item[1..] if item.length > 1
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
  arr.reverse().map (item) ->
    if Array.isArray item then reverse item
    else item.split('').reverse().join ''

reverse_action = (action) ->
  store = reverse store
  do action
  store = reverse store

end = -> reverse_action home

remove  = ->
  if cursor in store
    store = [cursor]
    return 'done'
  recursion = (arr) ->
    arr.map (x) ->
      if Array.isArray x
        if cursor in x then cursor else (recursion x)
      else
        if (x.indexOf cursor) is -1 then x else cursor
  store = recursion store

left = ->
  if store[0] is cursor then return 'skip'
  recursion = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item
        if item[0] is cursor
          copy.push cursor
          copy.push item[1..] if item.length > 1
        else copy.push (recursion item)
      else if item is cursor
        # console.log 'copy: ', copy
        last_item = copy.pop()
        if Array.isArray last_item
          last_item.push cursor
          copy.push last_item
        else copy.push "#{last_item}#{cursor}"
      else
        # console.log 'all strings', item
        if item[0] is cursor
          copy.push cursor
          copy.push item[1..] if item.length > 1
        else
          point = item.indexOf cursor
          # console.log 'find? ', find_cursor
          if point < 0 then copy.push item
          else 
            item[point..point+1] = [cursor, item[point-1]]
            copy.push item
    copy
  store = recursion store

right = -> reverse_action left

down = ->
  copy_tail = store.concat().reverse()
  for item in copy_tail
    if Array.isArray item then break
    if item in [cursor, [cursor]] then return 'skip'
    unless (item.indexOf cursor) is -1 then return 'skip'
  recursion = (arr) ->
    # console.log 'evenry time begin:: ', arr
    copy = []
    has_cursor = no
    for item in arr
      if item in [cursor, [cursor]] then has_cursor = yes
      else if typeof item is 'string'
        if item.match(new RegExp cursor)?
          copy.push (item.replace cursor, '')
          has_cursor = yes
        else copy.push item
      else
        # console.log 'else... ', item
        if has_cursor
          item.unshift cursor
          copy.push item
          has_cursor = off
        else
          obj = recursion item
          copy.push obj.value
          if obj.has_cursor then copy.push cursor
    obj =
      value: copy
      has_cursor: has_cursor
  store = (recursion store).value
  # console.log 'result: ', store

up = -> reverse_action down

left_step = ->
  recursion = (arr) ->
    if arr[0] is cursor then return arr
    copy = []
    for item in arr
      if Array.isArray item then copy.push (recursion item)
      else if item is cursor
        last_item = copy.pop()
        copy.push cursor, last_item
      else
        if (item.indexOf cursor) is -1 then copy.push item
        else copy.push cursor, item.replace(cursor, '')
    copy
  store = recursion store

right_step = -> reverse_action left_step

snippet = null

ctrl_copy = ->
  recursion = (arr) ->
    for item in arr
      if Array.isArray item
        if cursor in item
          snippet = item.filter (x) -> x isnt cursor
        else recursion item
      else if item.indexOf(cursor) >= 0
        snippet = item.replace cursor, ''
  recursion store
  # console.log snippet

ctrl_cut = ->
  if cursor in store then return 'skip'
  recursion = (arr) ->
    arr.map (item) ->
      if cursor in item
        snippet = item.filter (x) -> x isnt cursor
        return cursor
      else if Array.isArray item then return recursion item
      else return item
  store = recursion store
  # console.log snippet

ctrl_paste = ->
  recursion = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item then copy.push (recursion item)
      else if item is cursor then copy.push snippet, cursor
      else if (item.indexOf cursor) < 0 then copy.push item
      else copy.push snippet, item
    copy
  store = recursion store if snippet?

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
    commit: prompt('add phrase to commit')
  )
  last_item = version_cursor.child
  # console.log 'last_item: ', last_item
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

view_version = ->
  recursion = (obj) ->
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
        result = recursion item
        # console.log 'result: ', result
        footer.appendChild result
    footer
  tag('box').innerHTML = ''
  tag('box').appendChild (recursion version_map)
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

go_back = ->
  console.log 'current: ', current
  if history[current-1]?
    store = history[current-1]
    current-= 1
    (tag 'box').innerHTML = draw store

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