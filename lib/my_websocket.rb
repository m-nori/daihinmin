# -*- coding:utf-8 -*-

APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
require 'msgpack/rpc'

class MyWebsocket
  @@ws = MessagePack::RPC::Client.new('127.0.0.1', 18800)

  def MyWebsocket.call(data)
    @@ws.call(:push_data, data)
  end
end

