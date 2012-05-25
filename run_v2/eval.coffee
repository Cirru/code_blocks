
echo = console.log

scope_zero =
  here: {}
  seek: (key) ->
    if @here[key]? then @here[key] else undefined

scope_new = (parent) ->
  obj =
    here: {}
    parent: parent
    seek: (key) ->
      if @here[key]? then @here[key] else @parent.seek key

scope_zero.here.zero = 'N'
alice = scope_new scope_zero
console.log (alice.seek 'zero')