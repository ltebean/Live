This is project is to demonstrate how to build a live broadcast app. It include these features:

* create a room to broadcast your live stream
* join a room to watch the live
* send upvotes and comments


## Introduction

* RTMP server - Nginx RTMP module(https://github.com/arut/nginx-rtmp-module)
* WebSocket server - Socket.io(http://socket.io/)
* iOS client - VideoCore(https://github.com/jgh-/VideoCore) for push stream, IJKPlayer(https://github.com/Bilibili/ijkplayer) to play stream

## How to run

#### 1. Nginx RTMP server

You need to set up your own rtmp server, the guidance can be found here: https://github.com/arut/nginx-rtmp-module


#### 2. WebSocket server

Just go to the live-server folder, run `npm install`, then start the server by `node app.js`

#### 3. iOS client

Go the the project room folder, run `pod install`(must use cocoapods 0.39.0)

Download `IJKMediaFramework.framework` then add it into the project.
