
ll = console.log

new_scope = (parent) ->
  obj =
    pattern: []
    varable: {}
    parent:  parent
    seek_varable: (str) ->
      if @varable[str]? then @varable
      else
        if @parent? then @parent.seek_varable str
        else null
    seek_pattern: ->
      if @parent?
        @pattern.concat @parent.seek_pattern()
      else @pattern

global_scope =
  pattern: []
  varable:
    aa: 'nothi'
  seek_varable: (str) ->
    if @varable[str]? then @varable
    else undefined
  seek_pattern: -> @pattern

arr_lines = (v...) -> v[1..]
_ = 0
obj_lines = (a, b) -> b

default_pattern = arr_lines _,
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '+'
    handler: (arg) -> arg.reduce (x, y) -> x + y
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '-'
    handler: (arg) -> arg.reduce (x, y) -> x - y
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '*'
    handler: (arg) -> arg.reduce (x, y) -> x * y
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '/'
    handler: (arg) -> arg.reduce (x, y) -> x / y
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '/'
    handler: (arg) -> arg.reduce (x, y) -> x / y
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '/'
    handler: (arg) -> arg.reduce (x, y) -> x / y
  obj_lines _,
    pattern: (arr) -> calculator_pattern arr, '%'
    handler: (arg) -> arg.reduce (x, y) -> x % y

for item in default_pattern
  global_scope.pattern.push item

calculator_pattern = (arr, method) ->
  unless arr.shift() is method then return null
  args = []
  for item in arr
    if Array.isArray item then as_number = run item
    else as_number = Number item
    if isNaN as_number then return null
    args.push as_number
  args

run = (arr, scope) ->
  for item in scope.pattern
    if (args = item.pattern arr.concat())?
      # failed while there was no concat!
      return item.handler args.concat()
  throw new Error 'no such macro!'

ll (run ['+', '1', '2', '3'], global_scope)
ll (run ['-', '1', '2', '3'], global_scope)
ll (run ['*', '1', '2', '3'], global_scope)
ll (run ['/', '1', '2', '3'], global_scope)
ll (run ['%', '4', '456', '3'], global_scope)