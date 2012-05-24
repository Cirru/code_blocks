
{spawn} = require 'child_process'
{print} = require 'util'
fs = require 'fs'

coffee_file = 'convert.coffee' 
coffee_eval = 'run/eval.coffee'
jade_file   = 'html.jade'
stylus_file = 'page.styl'

fs.watchFile coffee_file, (e) ->
  console.log e
  result = spawn 'coffee', ['-bc', coffee_file]
  msg = ''
  result.stderr.on 'data', (str) ->
    msg+= str
  result.stderr.on 'end', ->
    console.log 'msg: ', msg
  print "!! #{coffee_file}\n"

fs.watchFile coffee_eval, (e) ->
  result = spawn 'coffee', ['-bc', coffee_eval]
  msg = ''
  result.stderr.on 'data', (str) ->
    msg+= str
  result.stderr.on 'end', ->
    console.log 'msg: ', msg
  print "!! #{coffee_eval}\n"

fs.watchFile jade_file, ->
  spawn 'jade', [jade_file]
  print "!! #{jade_file}\n"

fs.watchFile stylus_file, ->
  spawn 'stylus', [stylus_file]
  print "!! #{stylus_file}\n"