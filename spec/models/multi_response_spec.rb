require "spec_helper"

include Rmpd


describe Rmpd::MultiResponse do
  describe "on success" do
    before(:each) do
      data = <<-EOF
foo: cat
bar: dog
foo: horse
bar: giraffe
OK
EOF
      @response = Rmpd::MultiResponse.new(data, /(^foo:)/)
    end

    it "should have a size of 2" do
      @response.should have(2).items, @response.inspect
    end

    it "should be OK" do
      # @response.should be_ok
      # doesn't work correctly, see rspec bug #11526
      @response.ok?.should be_true
    end

    it "should not be ACK" do
      # @response.should_not be_ack
      # doesn't work correctly, see rspec bug #11526
      @response.ack?.should be_false
    end
  end

  describe "on error" do
    before(:each) do
      @err_msg = "ACK [2@0] {search} too few arguments for \"search\"\n"
      @response = Rmpd::MultiResponse.new(@err_msg, /(^foo:)/)
    end

    it "should not be OK" do
      # @response.should_not be_ok
      # doesn't work correctly, see rspec bug #11526
      @response.ok?.should be_false
    end

    it "should be ACK" do
      # @response.should be_ack
      # doesn't work correctly, see rspec bug #11526
      @response.ack?.should be_true
    end
  end
end
