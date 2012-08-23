module Rmpd
  module Commands

    private

    def self.simple_command(name, args={})
      block = lambda do |*a|
        # if args.include?(:min_version)
        #   server_version_at_least(*args[:min_version])
        # end
        Command.new(name.to_s.gsub(/^_*/, ""), nil, *quote(a)).execute
      end
      send(:define_method, name, &block)
    end

    def self.complex_command(mpd, name, args={})
      args = {:regexp => /(^file: )/i}.merge(args)
      block = lambda do |*a|
        # if args.include?(:min_version)
        #   server_version_at_least(*args[:min_version])
        # end
        # send_command(name.to_s.gsub(/^_*/, ""), *quote(a))
        # if @in_command_list
        #   append_command_list_regexp(args[:regexp])
        # else
        #   read_responses(args[:regexp])
        # end
        Command.new(mpd, name.to_s.gsub(/^_*/, ""), args[:regexp], *quote(a)).execute
      end
      send(:define_method, name, &block)
    end

    # def append_command_list_regexp(regexp)
    #   if @in_command_list_response_regexp
    #     @in_command_list_response_regexp = \
    #       Regexp.union(@in_command_list_response_regexp, regexp)
    #   else
    #     @in_command_list_response_regexp = regexp
    #   end
    # end

    def quote(args)
      args.collect {|arg| "\"#{arg.to_s.gsub(/"/, "\\\"")}\""}
    end
  end

end
