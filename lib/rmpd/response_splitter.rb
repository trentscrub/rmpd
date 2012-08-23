module Rmpd
  class ResponseSplitter

    def self.split(lines, responses=[])
      known_keys = []
      response_lines = []

      lines.each do |line|
        if KEY_VALUE_RE === line
          key, value = $~.values_at(1..2)
          if known_keys.include?(key)
            yield responses, response_lines
            response_lines.clear
            known_keys.clear
          end

          response_lines << line
          known_keys << key
        end
      end

      yield responses, response_lines
    end

  end
end
