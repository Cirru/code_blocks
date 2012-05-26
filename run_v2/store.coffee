
app = (require 'http').createServer (req, res) -> res.end 'hi'
io = (require 'socket.io').listen app
app.listen 8000

store = ['\t']

io.sockets.on 'connection', (s) ->
  s.on 'sync', (data) ->
    store = data
  s.emit 'new', store