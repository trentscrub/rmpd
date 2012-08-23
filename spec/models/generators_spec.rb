require "spec_helper"

module Rmpd
  describe Commands, "Generators" do

    before(:each) do
      pending "Do I care anymore?"
      @config = mock_config
      @socket = mock_socket
      @conn = Connection.new
    end

    describe "when version is ok" do

      before(:each) do
        version = "0.1.1"
        responses = connect_response(version) + ok
        @socket.should_receive(:readline).and_return(*responses)
      end

      describe "simple_command" do
        it "should allow based on server version" do
          pending "Do I care anymore?"
          Commands::simple_command(:test, :min_version => [0, 1, 1])
          lambda do
            @conn.test
          end.should_not raise_error(MpdError)
        end
      end
    end

    describe "when version is NOT ok" do

      before(:each) do
        version = "0.1.1"
        responses = connect_response(version)
        @socket.should_receive(:readline).and_return(*responses)
      end

      describe "simple_command" do
        it "should disallow based on server version" do
          Rmpd::Commands::simple_command(:test, :min_version => [0, 1, 2])
          lambda do
            @conn.test
          end.should raise_error(MpdError, /^Requires server version/)
        end
      end

      describe "complex_command" do
        it "should disallow based on server version" do
          Rmpd::Commands::complex_command(:test, :min_version => [0, 1, 2])
          lambda do
            @conn.test
          end.should raise_error(MpdError, /^Requires server version/)
        end
      end
    end
  end
end
