module OFX
  class Foundation
    def initialize(attrs)
      attrs.each do |key, value|
        send("#{key}=", value)
      end
    end
  end
end