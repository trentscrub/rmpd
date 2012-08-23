require "delegate"
require "forwardable"


module Rmpd
  class Command

    def self.new(connection, name, splitter=nil, *args, &block)
      obj = super
      obj.extend(choose_strategy(name, splitter))
    end

    def initialize(connection, name, splitter=nil, *args, &block)
      @mpd = connection
      @name = name
      @args = args
      @splitter = splitter
      @list = initialize_list(&block) if block_given?
    end


    private

    def self.choose_strategy(name, splitter)
      if /command_list_ok/ === name
        CommandListOkStrategy
      elsif /command_list/ === name
        CommandListStrategy
      elsif splitter
        CommandMultiStrategy
      else
        CommandStrategy
      end
    end

    def initialize_list
      list = List.new(@mpd)
      yield list
      list
    end

    module CommandStrategy
      def execute
        @mpd.send_command(*process)
        Response.new(@mpd.read_response)
      end

      def process
        [@name, *@args]
      end
    end

    module CommandMultiStrategy
      def execute
        splitter = Splitter.new(@splitter)

        @mpd.send_command(*process)
        splitter.split(@mpd.read_response).map do |chunk|
          Response.new(chunk)
        end
      end

      def process
        [@name, *@args]
      end
    end

    module CommandListStrategy
      def execute
        @mpd.send_command("command_list_begin")
        @list.map(&:process).map do |args|
          @mpd.send_command(*args)
        end
        @mpd.send_command("command_list_end")
        Response.new(@mpd.read_response)
      end
    end

    module CommandListOkStrategy
      def execute
        @mpd.send_command("command_list_ok_begin")
        @list.map(&:process).map do |args|
          @mpd.send_command(*args)
        end
        @mpd.send_command("command_list_end")

        handle_command_list_ok_response(@mpd.read_response)
      end


      private

      def handle_command_list_ok_response(lines)
        lines.pop while lines.last =~ LIST_OK_RE || lines.last =~ OK_RE

        ResponseArray.new(split_responses(lines))
      end

      def split_responses(lines)
        lines.reduce([[]]) do |ra, line|
          if LIST_OK_RE === line
            ra << []
          else
            ra.last << line
          end
          ra
        end.map {|response| Response.new(response)}
      end

    end

    class ResponseArray < DelegateClass(Array)

      def ok?
        all?(&:ok?)
      end

      def ack?
        !ok?
      end

      def error
        find {|e| e.ack?}.error if ack?
      end

    end

    class List
      extend Forwardable

      def_delegators :@cmds, :empty?, :each, :map, :size

      def initialize(mpd)
        @mpd = mpd
        @cmds = []
      end


      protected

      def method_missing(name, *args, &block)
        @cmds << Command.new(@mpd, name.to_s, *args, &block)
      end
    end

    class Splitter
      def initialize(regexp)
        @regexp = regexp
      end

      def split(lines)
        lines.reduce([]) do |c, i|
          if @regexp === i
            c << [i]
          else
            c.last << i
          end
          c
        end
      end
    end

  end
end
