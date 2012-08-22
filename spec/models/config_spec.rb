require "spec_helper"

include Rmpd


describe Rmpd::Config do

  before(:each) do
    @filename = File.join(File.dirname(__FILE__), "../../spec/fixtures/config.yml")
  end

  describe "initialization" do
    it "should parse successfully" do
      lambda do
        Rmpd::Config.new(@filename)
      end.should_not raise_error
    end
  end

  describe "rails" do
    before(:each) do
      class Rails
        def self.env ; "development" ; end
      end
      @filename = File.join(File.dirname(__FILE__), "../../spec/fixtures/config_rails.yml")
    end

    after(:each) do
      Object.send(:remove_const, :Rails) if defined?(Rails)
    end

    it "should load the development environment" do
      lambda do
        Rmpd::Config.new(@filename)
      end.should_not raise_error
    end

    it "should load the development environment" do
      config = Rmpd::Config.new(@filename)
      config.hostname.should == "localhost"
      config.port.should == 3000
    end
  end

  describe "operation" do
    before(:each) do
      @config = Rmpd::Config.new(@filename)
    end

    it "should have the correct port" do
      1234.should == @config.port
    end

    it "should have the correct hostname" do
      @config.hostname.should == "test.host"
    end

    it "should have the correct password" do
      @config.password.should == "juggernaught"
    end
  end

  describe "without password" do
    before(:each) do
      @filename = File.join(File.dirname(__FILE__), "../../spec/fixtures/config_no_password.yml")
      @config = Rmpd::Config.new(@filename)
    end

    it "should have the default password" do
      @config.password.should == Rmpd::Config::DEFAULT_PASSWORD
    end
  end

  describe "without hostname" do
    before(:each) do
      @filename = File.join(File.dirname(__FILE__), "../../spec/fixtures/config_no_hostname.yml")
      @config = Rmpd::Config.new(@filename)
    end

    it "should have the default hostname" do
      @config.hostname.should == Rmpd::Config::DEFAULT_HOSTNAME
    end
  end

  describe "without port" do
    before(:each) do
      @filename = File.join(File.dirname(__FILE__), "../../spec/fixtures/config_no_port.yml")
      @config = Rmpd::Config.new(@filename)
    end

    it "should have the default port" do
      @config.port.should == Rmpd::Config::DEFAULT_PORT
    end
  end

  describe "by default" do
    before(:each) do
      @filename = nil
      ENV["MPD_HOST"] = nil
      ENV["MPD_PORT"] = nil
      @config = Rmpd::Config.new(@filename)
    end

    it "should have the default hostname" do
      @config.hostname.should == Rmpd::Config::DEFAULT_HOSTNAME
    end

    it "should have the default port" do
      @config.port.should == Rmpd::Config::DEFAULT_PORT
    end

    it "should have the default password" do
      @config.password.should == Rmpd::Config::DEFAULT_PASSWORD
    end
  end

  describe "with environment variables set" do
    before(:each) do
      ENV["MPD_HOST"] = "testing:host"
      ENV["MPD_PORT"] = -1.to_s
      @config = Rmpd::Config.new
    end

    it "should pickup the environment's host" do
      @config.hostname.should == ENV["MPD_HOST"]
    end

    it "should pickup the environment's port" do
      @config.port.should == ENV["MPD_PORT"].to_i
    end
  end
end
