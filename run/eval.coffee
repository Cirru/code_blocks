
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
      console.log @pattern.concat @parent.seek_pattern()
      @pattern.concat @parent.seek_pattern()
    else @pattern

global_scope =
  pattern: ['0']
  varable:
    aa: 'nothi'
  seek_varable: (str) ->
    if @varable[str]? then @varable[str]
    else undefined
  seek_pattern: -> @pattern

one = new Scope global_scope
two = new Scope one
console.log two.pattern
one.pattern.push 3,5,6
console.log two.pattern

console.log (two.seek_varable 'aa')
one.varable.aa = 'xx'
console.log (two.seek_varable 'aa')
console.log '--------------'
console.log two.seek_pattern()