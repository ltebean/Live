This project is to demonstrate how to build a live broadcast app. It include these features:

* Create a room to broadcast your live stream
* Join a room to watch the live
* Send likes, gifts, and comments

![image](https://cloud.githubusercontent.com/assets/1646564/16943747/de7a0c36-4dcf-11e6-913f-103301ef8fda.png)&emsp;&emsp;![image](https://cloud.githubusercontent.com/assets/1646564/16943754/e1d036ee-4dcf-11e6-8994-cc2cf1709bb8.png)

## Introduction

* RTMP server - Nginx RTMP module(https://github.com/arut/nginx-rtmp-module)
* WebSocket server - Socket.io(http://socket.io/)
* iOS client - LFLiveKit(https://github.com/LaiFengiOS/LFLiveKit) to push stream, IJKPlayer(https://github.com/Bilibili/ijkplayer) to play stream

## How to run

I've set up a test server at 139.196.179.230, so you can directly run the iOS project.

#### 1. Nginx RTMP server

You can set up your own rtmp server, the guidance can be found here: 

* https://github.com/arut/nginx-rtmp-module
* https://www.atlantic.net/community/howto/install-rtmp-ubuntu-14-04/


#### 2. WebSocket server

Just go to the `live-server` folder, run `npm install`, then start the server by `node app.js`

#### 3. iOS client

Go to the `live-ios` folder, run `pod install`(must use cocoapods 0.39.0)

In Config.swift, update the server url:
```
struct Config {
    static var rtmpPushUrl = "rtmp://139.196.179.230/mytv/"
    static var rtmpPlayUrl = "rtmp://139.196.179.230/mytv/"
    static var serverUrl = "http://139.196.179.230:3000"
}

```

The app can also run on a simulator, but to broadcast, you need to run it on a real device.


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

Some explaination for RTMP and HLS:

* RTMP: RTMP is used to stream audio, video or data and is originally a proprietary protocol introduced by Macromedia (owned by Adobe). The protocol is TCP-based and offers therefore persistent connections. In short, RTMP encapsulates MP3/AAC audio and MP4/FLV video multimedia streams.

* HLS: HTTP Live Streaming is known as HLS. As the name implies, it is the media streaming communications protocol based on HTTP; developed by Apple as part of their QuickTime, Safari, OS X, and iOS products. How does it work? It breaks the overall stream into a sequence of small HTTP-based files (.ts: Transport Stream). These transport stream files are indexed in the file .m3u8. It is required to download first the .m3u8 playlist to play a live stream.

For the media server, there are serveral choices:
* Adobe media server
* Red5
* Nginx RTMP module
* crtmpserver

After setting up the server, you can test it using ffmpeg(install it by `brew install ffmpeg`).
* push stream
```
ffmpeg -f avfoundation -framerate 30  -i "1:0" -f flv rtmp://server-url
```

* watch the stream: go to this site: https://www.hlsplayer.net/rtmp-player


p.s. Lots of live stream cloud already covers the media server and cdn parts. You just need to push/pull the stream from it.


#### 2. iOS RTMP libs
There are serveral open source projects supporting RTMP, this project uses:
* LFLiveKit(https://github.com/LaiFengiOS/LFLiveKit) to push rtmp stream
* IJKPlayer(https://github.com/Bilibili/ijkplayer) to pull rtmp stream

You can find the usage of these libs in their project pages.


#### 3. Websocket server
This project uses socket.io to handle the client-server communication, the logic is very simple, on the server side:
```js
var rooms = {}

io.on('connection', function(socket) {

  socket.on('create_room', function(room) {
    var roomKey = room.key
    rooms[roomKey] = room
    socket.roomKey = roomKey
    socket.join(roomKey)
  })

  socket.on('close_room', function(roomKey) {
    delete rooms[roomKey]
  })

  socket.on('disconnect', function() {
    if (socket.roomKey) {
      delete rooms[socket.roomKey]
    }
  })

  socket.on('join_room', function(roomKey) {
    socket.join(roomKey)
  })

  socket.on('upvote', function(roomKey) {
    io.to(roomKey).emit('upvote')
  })

  socket.on('gift', function(data) {
    io.to(data.roomKey).emit('gift', data)
  })
  
})

```

On the client side, it uses the socket.io swift client(https://github.com/socketio/socket.io-client-swift), the logic is also simple:

create, join, or close a room:
```swift
socket.on("connect") { data, ack in
    self.socket.emit("create_room", self.room)
}

socket.on("connect") { data, ack in
    self.socket.emit("join_room", self.room.key)
}

socket.disconnect()
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
socket.on("upvote") { data, ack in
    self.emitterView.emitImage(R.image.heart()!)
}
        
socket.on("comment") { data, ack in
    let comment = Comment(dict: data[0] as! [String: AnyObject])
    self.comments.append(comment)
    self.tableView.reloadData()
}
```



