
ll = console.log

new_scope = (parent) ->
  obj =
    pattern: []
    varable: {}
    parent:  parent
    find_varable: (str) ->
      if @varable[str]? then @varable
      else if @parent? then @parent.find_varable str else skip
    find_pattern: ->
      more = if @parent? then @parent.find_pattern() else @pattern
      @pattern.concat more

global_scope =
  pattern: []
  varable:
    aa: 'nothi'
  find_varable: (str, scope) ->
    if @varable[str]? then @varable else undefined
  find_pattern: -> @pattern

__ = (v...) -> v[1..]
_ = 0

skip = 'skip while pattern not matching'

default_pattern = __ _,
  (arr, scope) ->
    if arr[1] in ('+-*/%'.split '')
      varable = arr.shift()
      method = arr.shift()
    else if arr[0] in ('+-*/%'.split '')
      method = arr.shift()
    else return skip
    if varable?
      find_varable = scope.find_varable varable
      return skip unless (target = find_varable)?
      arr.unshift target[varable]
    args = []
    for item in arr
      if Array.isArray item then args.push (run item, scope)
      else 
        as_number = Number item
        return skip if isNaN as_number
        args.push as_number
    result = args.reduce (x, y) ->
      switch method
        when '+' then x + y
        when '-' then x - y
        when '*' then x * y
        when '/' then x / y
        when '%' then x % y
    target[varable] = result if varable?
    result

  (arr, scope) ->
    return skip unless arr[1] in ['put', '=']
    return skip unless arr.length >= 3
    varable = arr[0]
    args = arr[2..].map (item) ->
      if Array.isArray item then run item, scope else item
    find_varable = scope.find_varable varable
    target = if find_varable? then find_varable else scope
    value = if args.length is 1 then args[0] else args
    target.varable[varable] = value

  (arr, scope) ->
    return skip unless arr[0] in ['echo', 'log']
    return skip unless arr.length >= 2
    args = arr[1..]
    content = args.map (item) ->
      if Array.isArray item then run item, scope
      else 
        find_varable = scope.find_varable item
        if find_varable? then find_varable[item]
        else '(undefined)'
    console.log.apply scope, content
    content

  (arr, scope) ->
    return skip unless arr.shift() is 'array'
    return skip unless arr.length > 0
    arr.map (item) ->
      if Array.isArray item then run item, scope
      else 
        as_number = Number item
        if isNaN as_number then item else as_number

  (arr, scope) ->
    return skip unless arr.shift() is 'number'
    return skip unless arr.length > 0
    if arr.length is 1
      if isNaN (Number arr[0]) then return skip
    copy = []
    for item in arr
      if Array.isArray item then run item, scope
      else 
        as_number = Number item
        if isNaN as_number then return skip
        else copy.push as_number
    if copy.length is 0 then skip
    else if copy.length is 1 then arr[0]
    else copy

  (arr, scope) ->
    return skip unless arr.shift() is 'string'
    return skip unless arr.length > 0
    if arr.length is 1 then return (String arr[0])
    else return arr.map (item) -> String item

  (arr, scope) ->
    return skip unless arr.shift() is 'bool'
    copy = []
    for item in arr
      if item in ['yes', 'true', 'on', 'ok'] then copy.push true
      else if item in ['no', 'false', 'off'] then copy.push false
      else return skip
    if copy.length is 0 then skip
    else if copy.length is 1 then copy[0]
    else copy

  (arr, scope) ->
    return skip unless arr.length >= 3
    if arr.shift() is 'pattern' then ''
    else if arr[1] is 'pattern'
      varable = arr.shift()
      arr.shift()
    else return skip
    args = arr.shift()
    action = arr
    sub_scope = new_scope scope
    new_pattern = (arr, sub_scope) ->
      return skip unless arr.length >= args.length
      for item, index in args
        ll item
        if Array.isArray item
          sub_scope.varable[item[0]] = arr[index]
        else return skip unless arr[index] is item
      run item, sub_scope for item in action[0...]
      run action.reverse()[0], sub_scope
    scope.pattern.unshift new_pattern
    scope.varable[varable] = new_pattern if varable?
    new_pattern

  (arr, scope) ->
    return skip unless arr.shift() is 'array?'
    copy = []
    ll arr
    for item in arr
      if Array.isArray item
        result = run item, scope
        return skip if result is skip
      else
        varable = scope.find_varable item
        if varable? then result = varable[item]
        else return skip
      copy.push (Array.isArray item)
    if copy.length is 1 then copy[0] else copy

for item in default_pattern
  global_scope.pattern.push item

run = (arr, scope=global_scope) ->
  for pattern in scope.find_pattern()
    result = pattern arr.concat(), scope
    return result unless result is skip
  throw new Error 'no pattern found'

###
ll (run ['+', '2', ['/', '3', '3']], global_scope)
ll (run ['var', '=', ['+', '2', '3']], global_scope)
run ['echo', 'var', 'ert'], global_scope
ll run ['array', '2', '3'], global_scope
ll run ['number', '2', ['+', '2', '3'], '4'], global_scope
###

mk = (str) -> str.split ' '

run (mk 'echo a')
run ['a', 'put', ['number', '3']]
run (mk 'echo a')
run (mk 'a + 30 4')
run (mk 'echo a')
console.log '----------------'
run ['pattern', ['ll', ['b'], 'xx', ['c']], ['echo', ['string', '444']]]
run ['ll', 'qq', 'xx', 'ff']
console.log '----------------'
ll (run (mk 'number 2 3 4 4 5'))
ll (run (mk 'string 23_45'))
ll (run ['array?', ['array', '2']])