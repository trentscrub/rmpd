require "delegate"

module Rmpd

  class MultiResponse < DelegateClass(Array)

    END_OF_RECORD = "\0x1E" # from ASCII

    def initialize(data, sep)
      super([])
      @sep = sep
      parse(data)
    end

    def ok?
      self.all?(&:ok?)
    end

    def ack?
      !ok?
    end

    def error
      self.map(&:error).compact.first
    end


    private

    def parse(data)
      data.gsub!(@sep, "#{END_OF_RECORD}\\1")
      data.split(END_OF_RECORD).each do |datum|
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
