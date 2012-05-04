
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
  varable: {}
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
        find_varable = scope.find_varable item
        return skip unless find_varable?
        args.push find_varable[item]
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
    args = arr[2..]
    copy = []
    for item in args
      if Array.isArray item then copy.push (run item, scope)
      else
        find_varable = scope.find_varable item
        return skip unless find_varable?
        copy.push find_varable[item]
    find_varable = scope.find_varable varable
    target = if find_varable? then find_varable else scope
    value = if copy.length is 1 then copy[0] else copy
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
    else if copy.length is 1 then copy[0]
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
      if item in ['yes', 'true', 'on', 'ok', 'right']
        copy.push true
      else if item in ['no', 'false', 'off', 'wrong']
        copy.push false
      else return skip
    if copy.length is 0 then skip
    else if copy.length is 1 then copy[0]
    else copy

  (arr, scope) ->
    return skip unless arr.length >= 3
    if arr[0] is 'pattern' then arr.shift()
    else if arr[1] is 'pattern'
      varable = arr.shift()
      arr.shift()
    else return skip
    args = arr.shift()
    action = arr
    new_pattern = (arr, get_scope) ->
      return skip unless arr.length >= args.length
      sub_scope = new_scope get_scope
      for item, index in args
        if Array.isArray item
          if Array.isArray arr[index]
            sub_scope.varable[item] =
              run arr[index], get_scope
          else
            find_varable = get_scope.find_varable arr[index]
            return skip unless find_varable?
            sub_scope.varable[item] = find_varable[arr[index]]
        else return skip unless arr[index] is item
      run item, sub_scope for item in action[0...]
      run action[action.length-1], sub_scope
    scope.pattern.unshift new_pattern
    scope.varable[varable] = new_pattern if varable?
    new_pattern

  (arr, scope) ->
    method = arr.shift()
    method_tail = method[method.length-1]
    method = method[...-1]
    return skip unless method_tail is '?' and typeis[method]?
    copy = []
    for item in arr
      if Array.isArray item
        result = run item, scope
        return skip if result is skip
      else
        varable = scope.find_varable item
        if varable? then result = varable[item]
        else return skip
      copy.push (typeis[method] result)
    if copy.length is 1 then copy[0] else copy

  (arr, scope) ->
    check = arr.shift()
    return skip unless arr.length >= 2
    return skip unless Array.isArray check
    return skip unless arr.shift() is 'then'
    find_else = arr.indexOf 'else'
    if find_else is -1 then true_action = arr
    else 
      true_action = arr[...find_else]
      false_action = arr[find_else+1..]
      return skip if true_action.length is 0
      return skip if false_action.length is 0
    right = run check, scope
    if right
      run item, scope for item in true_action[...-1]
      run true_action[true_action.length-1], scope
    else if (not right)
      if false_action?
        run item, scope for item in false_action[...-1]
        run false_action[false_action.length-1], scope
      else false
    else skip

  (arr, scope) ->
    return skip unless arr.length >= 3
    method = arr.shift()
    return skip unless compare[method]?
    copy = []
    for item in arr
      if Array.isArray item then copy.push (run item, scope)
      else 
        find_varable = scope.find_varable item
        if find_varable? then copy.push find_varable[item]
        else return skip
    base = copy.shift()
    for item in copy
      return false unless compare[method] base, item
      base = item
    true

for item in default_pattern
  global_scope.pattern.push item

typeis =
  array:  Array.isArray
  number: (item) -> not (isNaN item)
  bool:   (item) -> item in [true, false]
  string: (item) -> typeof item is 'string'
compare =
  '=': (x, y) -> x is y
  '>': (x, y) -> x > y
  '<': (x, y) -> x < y
  '<=': (x, y) -> x <= y
  '>=': (x, y) -> x >= y

run = (arr, scope=global_scope) ->
  # I hope to call the fastest available one
  # but now I'm only able to use the first available
  for pattern in scope.find_pattern()
    result = pattern arr.concat(), scope
    return result unless result is skip
  ll '::::pattern::::\n', arr
  throw new Error 'no pattern found'

###
ll (run ['+', '2', ['/', '3', '3']], global_scope)
ll (run ['var', '=', ['+', '2', '3']], global_scope)
run ['echo', 'var', 'ert'], global_scope
ll run ['array', '2', '3'], global_scope
ll run ['number', '2', ['+', '2', '3'], '4'], global_scope

mk = (str) -> str.split ' '

run (mk 'echo a')
run ['a', 'put', ['number', '3']]
run (mk 'echo a')
run (mk 'a + 30 4')
run (mk 'echo a')
console.log '----------------'
ll (run (mk 'number 2 3 4 4 5'))
ll (run (mk 'string 23_45'))
ll (run ['array?', ['array', '2']])
run (mk 'new put a')
run (mk 'log ss')
# ll (run ['number?', 'a'])
console.log '----------------'
run ['var', 'put', ['number', '3']]
run ['echo', 'var']
console.log '----------------'
run ['pattern', ['ll', ['b'], 'xx', ['c']], ['echo', ['+', '4', '34']]]
run ['ll', 'qq', 'xx', 'ff']
console.log '----------------'
ll (run ['=', ['number', '3'], ['number', '3'], ['number', '3']])
ll global_scope.pattern.length
###
run [
  'pattern',
  ['f', ['x']],
  [['>', 'x', ['number', '2']],
    'then', ['+',
      ['f', ['-', 'x', ['number', '1']]],
      ['f', ['-', 'x', ['number', '2']]],
    ]
    'else', ['number', '1']
  ]
]
ll (run ['f', ['number', '13']])