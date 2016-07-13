var app = require('express')();
var server = require('http').Server(app);
var io = require('socket.io')(server);

server.listen(3000);

app.get('/rooms', function(req, res) {
  res.send(rooms)
});


var rooms = []

function closeRoom(roomKey) {
  var index = rooms.indexOf(roomKey);
  if (index != -1) {
    rooms.splice(index, 1);
  }
}

io.on('connection', function(socket) {

  socket.on('create_room', function(roomKey) {
    console.log('create room:', roomKey)
    rooms.push(roomKey)
    socket.roomKey = roomKey;
    socket.join(roomKey);
  });

  socket.on('close_room', function(roomKey) {
    console.log('close room:', roomKey)
    closeRoom(roomKey)
  });

  socket.on('disconnect', function(roomKey) {
    if (socket.roomKey) {
      closeRoom(socket.roomKey)
    }
  });

  socket.on('join_room', function(roomKey) {
    console.log('join room:', roomKey)
    socket.join(roomKey);
  });

  socket.on('upvote', function(roomKey) {
    console.log('upvote:', roomKey)
    io.to(roomKey).emit('upvote')
  });

  socket.on('comment', function(data) {
    console.log('comment:', data)
    io.to(data.roomKey).emit('comment', data)
  });

});