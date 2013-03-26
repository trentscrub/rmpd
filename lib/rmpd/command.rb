require "delegate"
require "forwardable"


module Rmpd
  class Command

    def self.new(name)
      obj = super
      obj.extend(choose_strategy(name))
    end

    def initialize(name)
      @name = name
      @list = initialize_list(&block) if block_given?
    end


    private

    def self.choose_strategy(name)
      if /command_list_ok/ === name
        CommandListOkStrategy
      elsif /command_list/ === name
        CommandListStrategy
      elsif /noidle/ === name
        NoidleStrategy
      else
        CommandStrategy
      end
    end

    def initialize_list
      list = List.new
      yield list
      list
    end

    module NoidleStrategy

      def execute(connection, *args)
        connection.send_command(@name, *args)
        # The MPD server will never respond to a noidle command.
        # http://www.mail-archive.com/musicpd-dev-team@lists.sourceforge.net/msg02246.html
        nil
      rescue EOFError
        puts "NoidleStrategy EOFError received, retrying" if $DEBUG
        connection.close
        retry
      end

    end

    module CommandStrategy

      def execute(connection, *args)
        connection.send_command(@name, *args)
        Response.factory(@name).parse(connection.read_response)
      rescue EOFError
        puts "CommandStrategy EOFError received, retrying" if $DEBUG
        connection.close
        retry
      end

    end

    module CommandListStrategy

      def execute(connection, *args, &block)
        list = List.new
        yield list

        connection.send_command("command_list_begin")
        list.map do |command_w_args|
          connection.send_command(*command_w_args)
        end
        connection.send_command("command_list_end")
        Response.factory(@name).parse(connection.read_response)
      rescue EOFError
        puts "CommandListStrategy EOFError received, retrying" if $DEBUG
        connection.close
        retry
      end

    end

    module CommandListOkStrategy

      def execute(connection, *args, &block)
        @list = List.new
        yield @list

        connection.send_command("command_list_ok_begin")
        @list.map do |command_w_args|
          connection.send_command(*command_w_args)
        end
        connection.send_command("command_list_end")
        handle_command_list_ok_response(connection.read_response)
      rescue EOFError
        puts "CommandListOkStrategy EOFError received, retrying" if $DEBUG
        connection.close
        retry
      end


      private

      def handle_command_list_ok_response(lines)
        lines.pop while lines.last =~ LIST_OK_RE || lines.last =~ OK_RE
        ResponseArray.new(split_responses(lines))
      end

      def split_responses(lines)
        commands = @list.map(&:first)

        lines.reduce([[]]) do |ra, line|
          if LIST_OK_RE === line
            ra << []
          else
            ra.last << line
          end
          ra
        end.map do |response|
          Response.factory(commands.shift).parse(response)
        end
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

      def initialize
        @cmds = []
      end


      protected

      def method_missing(name, *args, &block)
        @cmds << [name.to_s, *args]
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
