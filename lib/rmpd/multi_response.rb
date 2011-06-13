require "delegate"

module Rmpd

  class MultiResponse < DelegateClass(Array)

    def initialize(data, sep)
      super([])
      @sep = sep
      parse(data)
    end

    def ok?
      self.all? {|x| x.ok?}
    end

    def ack?
      !ok?
    end

    def error
      self.find(nil) {|x| x.error}
    end


    private

    def parse(data)
      # 0x1E is the ASCII code for End of Record.
      data.gsub!(@sep, "\0x1E\\1")
      data.split("\0x1E").each do |datum|
        if datum.empty?
          next
        else
          r = Response.new(datum)
        end
        self << r unless r.keys.size.zero? && r.ok?
      end
    end
  end

end
