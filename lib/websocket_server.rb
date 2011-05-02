#!/usr/bin/env ruby
# -*- coding:utf-8 -*-

APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
require 'rev/websocket'
require 'msgpack/rpc'

$sockets = {}

class MyConnection < Rev::WebSocket
  # 接続されたら呼ばれる
  def on_open
    puts "WebSocket opened from '#{peeraddr[2]}': request=#{request.inspect}"
    $sockets[self] = self
  end

  # メッセージが届いたら呼ばれる
  def on_message(data)
    puts "WebSocket data received: '#{data}'"
  end

  # 切断されたら呼ばれる
  def on_close
    puts "WebSocket closed"
    $sockets.delete(self)
  end
end

class RPCServer
  # send to all browser
  def push_data(data)
    puts "push data* '#{data}'"
    $sockets.each_value {|sock|
      sock.send_message(data)
    }
    nil
  end
end

# イベントループを作成
loop = Rev::Loop.default

port = ARGV[0] || 8081

# イベントループにWebSocketサーバを登録
ws = Rev::WebSocketServer.new('0.0.0.0', port, MyConnection)
ws.attach(loop)

# 同じイベントループにRPCサーバも乗せる
rpc = MessagePack::RPC::Server.new(loop)
rpc.listen('127.0.0.1', 18800, RPCServer.new)

# イベントループを開始
loop.run

