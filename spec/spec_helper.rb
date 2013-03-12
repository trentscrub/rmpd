require File.dirname(__FILE__) + "/../lib/rmpd"


def mock_socket
  socket = mock(Socket)
  socket.stub!(:puts)
  socket.stub!(:closed?).and_return(false)
  socket.stub!(:connect)
  socket.stub!(:eof?).and_return(false)
  Socket.stub!(:pack_sockaddr_in).and_return("pack_sockaddr_in")
  Socket.stub!(:new).and_return(socket)
  socket
end

def mock_config(opts={})
  opts = {
    :hostname => Rmpd::Config::DEFAULT_HOSTNAME,
    :port => Rmpd::Config::DEFAULT_PORT,
    :password => Rmpd::Config::DEFAULT_PASSWORD,
  }.merge(opts)
  config = mock(Rmpd::Config)
  config.stub!(:hostname).and_return(opts[:hostname])
  config.stub!(:password).and_return(opts[:password])
  config.stub!(:port).and_return(opts[:port])
  Rmpd::Config.stub!(:new).and_return(config)
  config
end

def connect_response(version="0.12.0")
  ok("MPD #{version}")
end

def connect_and_auth_responses
  connect_response + ok
end

def playlist_id_response
  @id ||= 0
  ["Id: #{@id += 1}"]
end

def ok(txt="")
  txt ? ["OK #{txt}\n"] : ["OK\n"]
end

def ack(x=1, y=2, cmd="foo_command", msg="No one's home dopey!")
  ["ACK [#{x}@#{y}] {#{cmd}} #{msg}"]
end

def command_list_ok_responses
  ["Album: Foo\n", "list_OK\n", "Artist: Bar\n", "list_OK\n"]
end

def status_response
  ["volume: -1\n", "state: play\n",]
end
