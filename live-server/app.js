var app = require('express')();
var server = require('http').Server(app);
var io = require('socket.io')(server);

server.listen(3000);

app.get('/', function (req, res) {
  res.send(200)
});

io.on('connection', function (socket) {
  console.log('connection')

  socket.on('join', function (data) {
    console.log('join')
    socket.join('room');
  });

  socket.on('upvote', function (data) {
    console.log('upvote')
    io.to('room').emit('upvote')
  });

  socket.on('comment', function (data) {
    console.log('comment:', data)
    io.to('room').emit('comment', data)
  });

});