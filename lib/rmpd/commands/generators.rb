module Rmpd
  module Commands

    private

    def self.simple_command(name, args={})
      command = Proc.new do |*a, &block|
        # if args.include?(:min_version)
        #   server_version_at_least(*args[:min_version])
        # end
        Command.new(name.to_s.gsub(/^_*/, "")).execute(mpd, *a, &block)
      end
      send(:define_method, name, &command)
    end

    def quote(args)
      args.collect {|arg| "\"#{arg.to_s.gsub(/"/, "\\\"")}\""}
    end
  end

end
