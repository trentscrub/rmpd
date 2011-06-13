require "spec_helper"

include Rmpd

describe MpdAckError do
  before(:each) do
    @err_msg = "ACK [2@0] {search} too few arguments for \"search\""
    ACK_RE.match(@err_msg)
    @error = MpdAckError.new($~)
  end

  it "should generate a useful string message" do
    @error.to_s.should == @err_msg
  end
end
