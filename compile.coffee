
{spawn} = require 'child_process'
{print} = require 'util'
fs = require 'fs'

coffee_file = 'convert.coffee' 
jade_file   = 'html.jade'
stylus_file = 'page.styl'

fs.watchFile coffee_file, ->
  spawn 'coffee', ['-bc', coffee_file]
  print "!! #{coffee_file}\n"

fs.watchFile jade_file, ->
  spawn 'jade', [jade_file]
  print "!! #{jade_file}\n"

fs.watchFile stylus_file, ->
  spawn 'stylus', [stylus_file]
  print "!! #{stylus_file}\n"