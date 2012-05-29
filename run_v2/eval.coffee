
echo = (item) -> output.push (String item)
err = (str) -> throw new Error str

scope_zero =
  here: {}
  seek: (key) -> @here

scope_new = (parent) ->
  obj =
    here: {}
    parent: parent
    seek: (key) ->
      upper = @parent.seek key
      if (not @here[key]?) and upper? then upper
      else @here

runit = (scope, arr) ->
  here = scope.seek arr[0]
  unless here?
    console.log arr
    err 'no function found'
  else
    here[arr[0]] scope, arr[1..]

read = (scope, x) ->
  if Array.isArray x then runit scope, x else
    here = (scope.seek x) or scope.here
    here[x]

scope_zero.here =

  set: (scope, v) ->
    (scope.seek v[0])[v[0]] = (
      if v.length is 2 then read scope, v[1]
      else v[1..].map (x) -> read scope, x)

  echo: (scope, v) ->
    v = v.map (x) -> read scope, x
    echo.apply console, v
    v

  '+': (scope, v) ->
    v.map((x)-> read scope, x).reduce (x, y) ->
      (Number x) + (Number y)

  '-': (scope, v) ->
    v.map((x)-> read scope, x).reduce((x,y)-> x-y)

  number: (scope, v) ->
    v = v.map (x) -> Number x
    if v.length is 1 then v[0] else v

  string: (scope, v) -> v.join(' ')

  def: (scope, v) ->
    here = (scope.seek v[0][0]) or scope.here
    here[v[0][0]] = (scope_in, arr) ->
      scope_sub = scope_new scope
      for item, index in v[0][1..]
        scope_sub.here[item] = read scope_in, arr[index]
      runit scope_sub, exp for exp in v[1..]

  if: (scope, v) ->
    if runit scope, v[0] then read scope, v[1]
    else read scope, v[2]

  '>': (scope, v) ->
    v = v.map (x) -> read scope, x
    base = v.shift()
    for item in v
      return false if base <= item
      base = item
    true

run = (arr) ->
  runit scope_zero, arr
