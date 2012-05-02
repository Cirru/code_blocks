
new_scope = (parent) ->
  obj =
    pattern: []
    varable: {}
    parent:  parent
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
  pattern: ['c']
  varable:
    aa: 'nothi'
  seek_varable: (str) ->
    if @varable[str]? then @varable[str]
    else undefined
  seek_pattern: -> @pattern

one = new_scope global_scope
two = new_scope one
two.pattern.push 3,5,6

console.log two.seek_varable 'aa'
one.varable.aa = 'xx'
console.log two.seek_varable 'aa'
console.log '--------------'
console.log one.seek_pattern()
console.log two.seek_pattern()