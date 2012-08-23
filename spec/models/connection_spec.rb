require "spec_helper"

include Rmpd


describe Connection do

  before(:each) do
    @socket = mock_socket
    @config = mock_config
    @conn = Connection.new
  end

  def set_password(password="foobar")
    @config.stub!(:password).and_return(password)
  end

  it "should connect successfully" do
    responses = connect_response + ok
    @socket.should_receive(:readline).and_return(*responses)
    @conn.ping
  end

  it "should authenticate successfully" do
    responses = connect_and_auth_responses + ok
    set_password
    @socket.should_receive(:readline).and_return(*responses)
    @conn.ping
  end

  it "should generate a server version" do
    pending "Do I care anymore?"
    version = "0.1.2"
    responses = connect_response(version) + ok
    @socket.should_receive(:readline).and_return(*responses)
    @conn.ping # so we connect, and get the server version
    @conn.server_version.should == version
  end

  it "should handle connection failures gracefully" do
    @socket.stub!(:connect).and_raise(Errno::ECONNREFUSED.new("test"))
    lambda do
      @conn.ping
    end.should raise_error(Rmpd::MpdError)
  end

  it "should restrict access based on server version" do
    pending "Do I care anymore?"
    responses = connect_response("0.1.0")
    @socket.stub!(:readline).and_return(*responses)
    @conn.instance_eval do
      def sval(*args)
        server_version_at_least(*args)
      end
    end
    lambda do
      @conn.sval(0, 1, 2)
    end.should raise_error(MpdError)
    lambda do
      @conn.sval(0, 1, 0)
    end.should_not raise_error(MpdError)
  end
end
