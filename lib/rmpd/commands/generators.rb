module Rmpd
  module Commands

    private

    def self.simple_command(name, args={})
      block = lambda do |*a|
        if args.include?(:min_version)
          server_version_at_least(*args[:min_version])
        end
        send_command(name.to_s.gsub(/^_*/, ""), *quote(a))
        read_response
      end
      send(:define_method, name, &block)
    end

    def self.complex_command(name, args={})
      args = {:regexp => /(^file: )/i}.merge(args)
      block = lambda do |*a|
        if args.include?(:min_version)
          server_version_at_least(*args[:min_version])
        end
        send_command(name.to_s.gsub(/^_*/, ""), *quote(a))
        read_responses(args[:regexp])
      end
      send(:define_method, name, &block)
    end

    def quote(args)
      args.collect {|arg| "\"#{arg.to_s.gsub(/"/, "\\\"")}\""}
    end
  end

end
