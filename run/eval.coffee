
ll = console.log

new_scope = (parent) ->
  obj =
    pattern: []
    varable: {}
    parent:  parent
    find_varable: (str) ->
      if @varable[str]? then @varable
      else
        if @parent? then (@parent.find_varable str) else skip
    find_pattern: ->
      if @parent? then @pattern.concat @parent.find_pattern()
      else @pattern

global_scope =
  pattern: []
  varable:
    aa: 'nothi'
  find_varable: (str, scope) ->
    if @varable[str]? then @varable else undefined
  find_pattern: -> @pattern

arr_lines = (v...) -> v[1..]
_ = 0

skip = 'skip while pattern not matching'

default_pattern = arr_lines _,
  (arr, scope) ->
    method = arr.shift()
    return skip unless method in ['+', '-', '*', '/', '%']
    args = []
    for item in arr
      if Array.isArray item then as_number = run item, scope
      else as_number = Number item
      return skip if isNaN as_number
      args.push as_number
    args.reduce (x, y) ->
      switch method
        when '+' then x + y
        when '-' then x - y
        when '*' then x * y
        when '/' then x / y
        when '%' then x % y

  (arr, scope) ->
    return skip unless arr[1] in ['put', '=']
    return skip unless arr.length >= 3
    var_name = arr[0]
    args = arr[2..].map (item) ->
      if Array.isArray item then run item, scope else item
    find_varable = scope.find_varable var_name
    target = if find_varable? then find_varable else scope
    value = if args.length is 1 then args[0] else args
    target.varable[var_name] = value

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
    arr.map (item) ->
      if Array.isArray item then run item, scope
      else 
        as_number = Number item
        if isNaN as_number then item else as_number

for item in default_pattern
  global_scope.pattern.push item

run = (arr, scope) ->
  for pattern in scope.pattern
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