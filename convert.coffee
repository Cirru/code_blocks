
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
window.onload = ->
  box = tag 'box'
  window.focus()

  do refresh = ->
    box.innerHTML = draw store
    console.log 'Refreshing :::: ', store

  document.onkeypress = (e) ->
    char = String.fromCharCode e.keyCode
    # console.log 'target!', char, e.ctrlKey
    unless e.ctrlKey or e.altKey
      if char in add_inputs
        # console.log "(#{char}) in inputs"
        input char
        do refresh
      return false
  document.onkeydown = (e) ->
    if editor_mode is off
      editor_mode = on
      do refresh
      return false
    code = e.keyCode
    console.log 'keyCode .... ', code, e.ctrlKey
    unless e.ctrlKey or e.altKey
      if control[''+code]?
        do control[''+code]
        do refresh
        return false
    if e.ctrlKey and (not e.altKey)
      if control['c_'+code]?
        send_back = do control['c_'+code]
        unless send_back is 'no need to refresh'
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
  # console.log 'called to cancel'
  if store[0] is cursor
    return 'nothing to do'
  recursion = (arr) ->
    if cursor in arr
      return arr if arr[0] is cursor
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
          last_item = item.filter (x) -> x isnt cursor
          if last_item.length > 0 then copy.push last_item
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
          find_cursor = item.match (new RegExp cursor)
          # console.log 'find? ', find_cursor
          unless find_cursor? then copy.push item
          else 
            # console.log 'item to swap: ', item
            swapit = new RegExp "(.)#{cursor}"
            copy.push item.replace(swapit, "#{cursor}$1")
    copy
  store = recursion store

right = ->
  store = reverse store
  do left
  store = reverse store

down = ->
  copy_tail = store.concat().reverse()
  for item in copy_tail
    if Array.isArray item then break
    if item in [cursor, [cursor]] then return 'no need'
    if item.match(new RegExp cursor)? then return 'yeah'
  recursion = (arr) ->
    # console.log 'evenry time begin:: ', arr
    copy = []
    has_cursor = no
    for item in arr
      if item in [cursor, [cursor]] then has_cursor = yes
      else if typeof item is 'string'
        if item.match(new RegExp cursor)?
          copy.push item.replace((new RegExp cursor), '')
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

up = ->
  store = reverse store
  do down
  store = reverse store

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
        find_cursor = item.match (new RegExp cursor)
        unless find_cursor? then copy.push item
        else
          copy.push cursor, item.replace(cursor, '')
    copy
  store = recursion store

right_step = ->
  store = reverse store
  do left_step
  store = reverse store

snippet = null

ctrl_copy = ->
  recursion = (arr) ->
    for item in arr
      if Array.isArray item
        if cursor in item
          snippet = item.filter (x) -> x isnt cursor
          return 'got'
        recursion item
      else
        if item.indexOf(cursor) >= 0
          snippet = item.replace cursor, ''
          return 'got'
  recursion store
  # console.log snippet

ctrl_cut = ->
  if cursor in store then return 'wont do'
  recursion = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item
        if cursor in item
          copy.push cursor
          snippet = item.filter (x) -> x isnt cursor
        else copy.push (recursion item)
      else
        if item.indexOf(cursor) >= 0
          copy.push cursor
          snippet = item.replace(cursor, '')
        else copy.push item
    copy
  store = recursion store
  # console.log snippet

ctrl_paste = ->
  recursion = (arr) ->
    copy = []
    for item in arr
      if Array.isArray item then copy.push (recursion item)
      else if item is cursor then copy.push snippet, cursor
      else if item.indexOf(cursor) < 0 then copy.push item
      else copy.push snippet, item
    copy
  if snippet? then store = recursion store

version_map =
  store: store
  stemp: 'no time'
  child: [cursor]
  commit: 'root'

version_cursor = version_map

pair_num = (num) ->
  if num < 10 then (String num) else '0'+(String num)

save_version = ->
  date_obj = new Date()
  year = (String date_obj.getFullYear())[2..3]
  month = pair_num (date_obj.getMonth() + 1)
  date = pair_num date_obj.getDate()
  hour = pair_num date_obj.getHours()
  minute = pair_num date_obj.getMinutes()
  stemp = "#{year}/#{month}/#{date} #{hour}:#{minute}"
  version_cursor.child.pop()
  version_cursor.child.push (
    store:store,
    stemp:stemp,
    child:[],
    commit:prompt('need')
  )
  last_item = version_cursor.child
  console.log 'last_item: ', last_item
  version_cursor = version_cursor.child[last_item.length-1]
  version_cursor.child.push cursor
  console.log 'version :: ', version_map
  do view_version
  'no need to refresh'

choose_version = (new_version_cursor) ->
  version_cursor.child.pop()
  version_cursor = new_version_cursor
  store = version_cursor.store
  version_cursor.child.push cursor
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
      footer.innerHTML+= "#{obj.stemp}<br>"
      obj.child.forEach (item) ->
        result = recursion item
        console.log 'result: ', result
        footer.appendChild result
      footer.childNodes
    footer
  tag('box').innerHTML = ''
  tag('box').appendChild (recursion version_map)
  editor_mode = off
  'no need to refresh'

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
  'c_37': left_step
  'c_39': right_step
  'c_67': ctrl_copy
  'c_88': ctrl_cut
  'c_80': ctrl_paste
  'c_83': save_version
  'c_86': view_version