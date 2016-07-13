This project is to demonstrate how to build a live broadcast app. It include these features:

* create a room to broadcast your live stream
* join a room to watch the live
* send likes and comments

![image](https://cloud.githubusercontent.com/assets/1646564/16791969/658d8e66-48f6-11e6-8329-6e9ef7f43e75.png)


## Introduction

* RTMP server - Nginx RTMP module(https://github.com/arut/nginx-rtmp-module)
* WebSocket server - Socket.io(http://socket.io/)
* iOS client - VideoCore(https://github.com/jgh-/VideoCore) to push stream, IJKPlayer(https://github.com/Bilibili/ijkplayer) to play stream

## How to run

#### 1. Nginx RTMP server

You need to set up your own rtmp server, the guidance can be found here: https://github.com/arut/nginx-rtmp-module


#### 2. WebSocket server

Just go to the `live-server` folder, run `npm install`, then start the server by `node app.js`

#### 3. iOS client

Go the the `live-ios` folder, run `pod install`(must use cocoapods 0.39.0)

In Config.swift, update the server url:
```
struct Config {
    static var rtmpPushUrl = "rtmp://139.196.232.10/live/"
    static var rtmpPlayUrl = "rtmp://139.196.232.10/live/"
    static var serverUrl = "http://172.16.20.24:3000"
}

```

The app can also be run on a simulator, but to broadcast, you need to run it on a real device



## Tutorial

#### 1. Live streaming

The basic live streaming flow is:
```
broadcaster -> rtmp -> media server -> cdn -> rtmp or hls -> audience
```

For the simplest case, we don't need a cdn server, then the flow will be:
```
broadcaster -> rtmp -> media server -> rtmp or hls -> audience
```

That is, the boadcaster push the live stream using the RTMP protocal to a media server, the audience pull the stream from the server using RTMP or HLS protocal.

Some explaination for RTMP and HLS
* RTMP: RTMP is used to stream audio, video or data and is originally a proprietary protocol introduced by Macromedia (owned by Adobe). The protocol is TCP-based and offers therefore persistent connections. In short, RTMP encapsulates MP3/AAC audio and MP4/FLV video multimedia streams.

* HLS: HTTP Live Streaming is known as HLS. As the name implies, it is the media streaming communications protocol based on HTTP; developed by Apple as part of their QuickTime, Safari, OS X, and iOS products. How does it work? It breaks the overall stream into a sequence of small HTTP-based files (.ts: Transport Stream). These transport stream files are indexed in the file .m3u8. It is required to download first the .m3u8 playlist to play a live stream.

For the media server, there are serveral choices:
* Adobe media server
* Red5
* Nginx RTMP module
* crtmpserver

Lots of live stream cloud already covers the media server and cdn parts. You just need to push/pull the stream from it.


#### 2. iOS RTMP libs
There are serveral open source projects supporting RTMP, this project uses:
* VideoCore to push rtmp stream
* IJKPlayer to pull rtmp stream
You can find the usage of these libs in their project pages.


#### 3. Websocket server
This project uses socket.io to handle the client-server communication, the logic is very simple, on the server side:
```node.js
var rooms = []

io.on('connection', function(socket) {

  socket.on('create_room', function(roomKey) {
    rooms.push(roomKey)
    socket.roomKey = roomKey;
    socket.join(roomKey);
  });

  socket.on('close_room', function(roomKey) {
    closeRoom(roomKey)
  });

  socket.on('disconnect', function(roomKey) {
    if (socket.roomKey) {
      closeRoom(socket.roomKey)
    }
  });

  socket.on('join_room', function(roomKey) {
    socket.join(roomKey);
  });

  socket.on('upvote', function(roomKey) {
    io.to(roomKey).emit('upvote')
  });

  socket.on('comment', function(data) {
    io.to(data.roomKey).emit('comment', data)
  });
});

```

On the client side, it uses the socket.io swift client(https://github.com/socketio/socket.io-client-swift), the logic is also simple:

create, join, or close a room:
```swift
socket.on("connect") {data, ack in
    self.socket.emit("create_room", self.room.key)
}

socket.on("connect") {data, ack in
    self.socket.emit("join_room", self.room.key)
}

socket.emitWithAck("close_room", room.key)(timeoutAfter: 0) {data in
    self.socket.disconnect()
}
```

publish likes and comments events:
```swift
socket.emit("upvote", room.key)
socket.emit("comment", [
    "roomKey": room.key,
    "text": text
])
```

listen likes and comments events:
```swift
socket.on("upvote") {data ,ack in
    self.emitterView.emitImage(R.image.heart()!)
}
        
socket.on("comment") {data ,ack in
    let comment = Comment(dict: data[0] as! [String: AnyObject])
    self.comments.append(comment)
    self.tableView.reloadData()
}
```



