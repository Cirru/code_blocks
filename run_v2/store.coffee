
app = (require 'http').createServer (req, res) -> res.end 'hi'
io = (require 'socket.io').listen app
io.set 'log level', 1
app.listen 8000

store = ['\t']

io.sockets.on 'connection', (s) ->
  console.log 'a connection'
  s.on 'sync', (data) ->
    store = data
  s.emit 'new', store