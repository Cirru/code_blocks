
class Scope
  constructor: (@parent) ->
  pattern: []
  varable: {}
  seek_varable: (str) ->
    if @varable[str]? then @varable[str]
    else
      if @parent? then @parent.seek_varable str
      else null
  seek_pattern: ->
    if @parent?
      @pattern.concat @parent.seek_pattern()
    else @pattern

global_scope =
  pattern: ['0']
  varable:
    aa: 'nothi'
  seek_varable: (str) ->
    if @varable[str]?
      @varable[str]
    else undefined
  seek_pattern: -> @pattern

one = new Scope global_scope

console.log (one.seek_varable 'aa')