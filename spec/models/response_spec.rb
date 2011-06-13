require "spec_helper"

include Rmpd


describe Rmpd::Response do
  before(:each) do
    data = <<-EOF
foo: bar
OK
EOF
    @response = Rmpd::Response.new(data)
  end

  it "should have a foo method" do
    @response.respond_to?(:foo).should be_true
    @response.foo.should == "bar"
  end

  it "should have a foo key" do
    @response.should include(:foo)
    @response[:foo].should == "bar"
  end

  it "should be ok" do
    # @response.should be_ok
    # doesn't work correctly, see rspec bug #11526
    @response.ok?.should == true
  end

  it "should not be ack" do
    # @response.should_not be_ack
    # doesn't work correctly, see rspec bug #11526
    @response.ack?.should_not == true
  end
end
