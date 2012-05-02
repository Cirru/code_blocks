
class Scope
  constructor: (@parent) ->
  pattern: []
  varable: {}
  seek_varable: (str) ->
    if varable[str]? then varable[str]
    else if @parent? then @parent.seek_varable()
    else null
  seek_pattern: ->
    if @parent?
      @pattern.concat @parent.seek_pattern()
    else @pattern

global_scope =
  pattern: []
  varable: {}
  parent:  null
  seek_varable: (str) -> if varable[str]? then varable[str] else null
  seek_pattern: -> @pattern

one = new Scope global_scope

console.log one