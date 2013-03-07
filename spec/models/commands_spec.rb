require "spec_helper"

include Rmpd


shared_examples_for "a command with a song pos" do
  it "should pass along the song pos" do
    @socket.stub!(:readline).and_return(*@responses)
    @socket.stub!(:puts).and_return(@socket.puts)
    @socket.stub!(:eof?).and_return(false)
    @command.call
  end
end

describe Rmpd::Commands do

  before(:each) do
    @socket = mock_socket
    @config = mock_config
    Socket.stub!(:new).and_return(@socket)
    @conn = Connection.new
  end

  def set_password(password="foobar")
    @config.stub!(:password).and_return(password)
  end

  it "should handle a closed connection gracefully" do
    @socket.stub!(:puts).and_raise(EOFError)
    @socket.stub!(:readline).and_return(*(connect_response + ok))
    @socket.should_receive(:close).exactly(5).times
    lambda do
      @conn.ping
    end.should raise_error(Rmpd::MpdError, "Retry count exceeded")
  end

  it "should abort after a limited number of tries against a closed connection" do
    @socket.stub!(:puts).and_raise(EOFError)
    @socket.stub!(:readline).and_return(*(connect_response + ok))
    @socket.should_receive(:close).exactly(5).times
    lambda do
      @conn.ping
    end.should raise_error(MpdError, "Retry count exceeded")
  end

  describe "close" do
    it "should close the socket" do
      @socket.stub!(:readline).and_return(*connect_response)
      @socket.should_receive(:close).once
      @conn.ping
      @conn.close
    end
  end

  describe "volume" do
    it "should be deprecated" do
      set_password
      @socket.stub!(:readline).and_return(*connect_and_auth_responses)
      $stderr.should_receive(:puts).with(/deprecated/i)
      @conn.volume(0)
    end
  end

  describe "kill" do
    before(:each) do
      set_password
    end

    it "should kill the daemon" do
      @socket.should_receive(:puts).with("kill")
      @socket.stub!(:readline).and_return(*connect_and_auth_responses)
      @socket.should_receive(:close)
      @conn.kill
    end
  end

  describe "playlistinfo" do
    before(:each) do
      set_password
      @song_id = 1
      @cmd = "playlistinfo \"#{@song_id}\""
      @responses = connect_and_auth_responses + ["file: blah\n", "boobies: yay!\n"] + ok
      @command = Proc.new {@conn.playlistinfo(@song_id)}
    end

    it_should_behave_like "a command with a song pos"
  end

  describe "play" do
    before(:each) do
      set_password
      @song_id = 12
      @cmd = "play \"#{@song_id}\""
      @responses = connect_and_auth_responses + ok
      @command = Proc.new {@conn.play(@song_id)}
    end

    it_should_behave_like "a command with a song pos"
  end

  describe "delete" do
    before(:each) do
      set_password
      @song_id = 23
      @cmd = "delete \"#{@song_id}\""
      @responses = connect_and_auth_responses + ok
      @command = Proc.new {@conn.delete(@song_id)}
    end

    it_should_behave_like "a command with a song pos"
  end

  describe "command_list" do
    it "shouldn't wait for a response from the first command" do
      @responses = connect_response + ok
      @socket.stub!(:readline).and_return(*@responses)
      @socket.stub!(:puts).and_return(@socket.puts)
      @socket.stub!(:eof?).and_return(false)

      @conn.command_list do |c|
        c.status
        c.stats
      end
    end

    it "should handle multi responses" do
      @responses = connect_and_auth_responses + playlist_id_response + ok
      @socket.stub!(:readline).and_return(*@responses)
      @socket.stub!(:puts).and_return(@socket.puts)
      @socket.stub!(:eof?).and_return(false)

      @conn.command_list do |c|
        c.addid("foo")
      end
    end

    it "raises an error when in idle" do
      @responses = connect_and_auth_responses + playlist_id_response + ok
      @socket.stub!(:readline).and_return(*@responses)
      @socket.stub!(:puts).and_return(@socket.puts)
      @socket.stub!(:eof?).and_return(false)

      expect do
        @conn.idle
        @conn.command_list do |c|
          c.addid("foo")
        end
      end.to raise_error(MpdError)
    end
  end

  describe "command_list_ok" do
    it "should return a list of multi responses" do
      @responses = connect_response + command_list_ok_responses + ok
      @socket.stub!(:readline).and_return(*@responses)
      @socket.stub!(:puts).and_return(@socket.puts)
      @socket.stub!(:eof?).and_return(false)

      results = @conn.command_list_ok do |c|
        c.list("album")
        c.list("artist")
      end

      results.should have(2).items, results.pretty_inspect
    end
  end
end
