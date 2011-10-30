APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
require "EventMachine"

class WebsocketClient < EventMachine::Connection
  include EventMachine::Deferrable
  
  def initialize
    @callbacks = []
  end
  
  def self.connect(host, port, callback = nil, &block)
    EventMachine::connect(host, port, self) do |conn|
      conn.add_callback(callback) unless callback.nil?
      conn.add_callback(nil, &block) if block_given?
    end
  end  
  
  def add_callback callback = nil, &block
    @callbacks.push(callback || block)
  end

  def post_init
    # send_data "GET / HTTP/1.1\r\nHost: _\r\n\r\n"
    request = "GET / HTTP/1.1\r\n"
		request << "Upgrade: WebSocket\r\n"
		request << "Connection: Upgrade\r\n"
		request << "Host: 192.168.11.6\r\n"
		request << "Origin: TODO\r\n"
    request << "\r\n"
    send_data request
    @data = ""
    @handshake = false
    @index = 0
  end

  def receive_data data
    @data << data
    if !@handshake
      if @data =~ /[\n][\r]*[\n]/m
        if @data =~ /HTTP\/1.1 101 Web Socket Protocol Handshake/
          @handshake = true
          @data = ""
        else
          close_connection  
        end
        # puts "RECEIVED HTTP HEADER:"
        # $`.each {|line| puts ">>> #{line}" }
        # header =
        # if (!header.equals("")) {
      end  
    elsif @data =~ /^\x00(.*)\xff$/m
      @data.scan(/^\x00(.*)\xff$/m) do |message|
        # puts "RECEIVED HTTP MESSAGE: #{message}"
        @callbacks.each do |callback|
          callback.call message
        end  
      end  
      @data = ""
      @index += 1;
    end
  end

  def unbind
    puts "A connection has terminated"
  end    
end
