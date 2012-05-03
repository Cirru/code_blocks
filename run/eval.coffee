
ll = console.log

new_scope = (parent) ->
  obj =
    pattern: []
    varable: {}
    parent:  parent
    find_varable: (str) ->
      if @varable[str]? then @varable
      else
        if @parent? then @parent.find_varable str
        else null
    find_pattern: ->
      if @parent?
        @pattern.concat @parent.find_pattern()
      else @pattern

global_scope =
  pattern: []
  varable:
    aa: 'nothi'
  find_varable: (str, scope) ->
    if @varable[str]? then @varable
    else undefined
  find_pattern: -> @pattern

arr_lines = (v...) -> v[1..]
_ = 0
obj_lines = (a, b) -> b

default_pattern = arr_lines _,
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '+'
    handler: (args, scope) -> args.reduce (x, y) -> x + y
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '-'
    handler: (args, scope) -> args.reduce (x, y) -> x - y
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '*'
    handler: (args, scope) -> args.reduce (x, y) -> x * y
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '/'
    handler: (args, scope) -> args.reduce (x, y) -> x / y
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '/'
    handler: (args, scope) -> args.reduce (x, y) -> x / y
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '/'
    handler: (args, scope) -> args.reduce (x, y) -> x / y
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '%'
    handler: (args, scope) -> args.reduce (x, y) -> x % y

  obj_lines _,
    pattern: (arr) ->
      return null unless arr[1] in ['put', '=']
      return null unless arr.length >= 3
      args = [arr[0]].concat arr[2..]
    handler: (args, scope) ->
      var_name = args[0]
      arg_list = args[1..].map (item) ->
        if Array.isArray item then run item, scope
        else item
      find_varable = scope.find_varable var_name
      if find_varable? then varable = find_varable
      else varable = scope
      if arg_list.length is 1 then value = arg_list[0]
      else value = arg_list
      varable.varable[var_name] = value
      value

  obj_lines _,
    pattern: (arr) ->
      return null unless arr[0] in ['echo', 'log']
      return null unless arr.length >= 2
      args = arr[1..]
    handler: (args, scope) ->
      console.log.apply scope, args.map (item) ->
        if Array.isArray item then run item, scope
        else 
          find_varable = scope.find_varable item
          if find_varable? then find_varable[item]
          else '(undefined)'

  obj_lines _,
    pattern: (arr) ->
      return null unless arr.shift() is 'array'
      return null unless arr.length > 0
      ll arr
      args = arr
    handler: (args, scope) ->
      args.map (item) ->
        if Array.isArray item then run item, scope
        else 
          as_number = Number item
          if isNaN as_number then item else as_number

for item in default_pattern
  global_scope.pattern.push item

calculator_pattern = (arr, method) ->
  return null unless arr.shift() is method
  args = []
  for item in arr
    if Array.isArray item then as_number = run item, global_scope
    else as_number = Number item
    return null if isNaN as_number
    args.push as_number
  args

run = (arr, scope) ->
  for item in scope.pattern
    if (args = item.pattern arr.concat())?
      # failed while there was no concat!
      return item.handler args.concat(), scope
  throw new Error 'no such macro!'

ll (run ['+', '2', ['+', '3', '3']], global_scope)
ll (run ['var', '=', ['+', '2', '3']], global_scope)
# run ['echo', 'var', 'ert'], global_scope
ll run ['array', '2', '3'], global_scope