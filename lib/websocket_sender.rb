# -*- coding:utf-8 -*-
class WebsocketSender
  @@ws = MessagePack::RPC::Client.new('127.0.0.1', 18800)

  def WebsocketSender.call(data)
    @@ws.call(:push_data, data)
  end
end

