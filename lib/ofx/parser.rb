module OFX
  module Parser
    class Base
      attr_reader :headers
      attr_reader :body
      attr_reader :content
      attr_reader :parser

      def initialize(path)
        @content = open(path).read
        @headers, @body = prepare(content)

        @parser = case @headers["VERSION"]
        when "102"; OFX::Parser::OFX102.new(:headers => headers, :body => body)
        else
          raise OFX::Parser::InvalidVersion
        end
      end

      private
        def prepare(content)
          # Split headers & body
          headers, body = content.dup.split(/\n{2,}|:?<OFX>/, 2)        

          # Parse headers. When value is NONE, convert it to nil.
          headers = headers.to_enum(:each_line).inject({}) do |memo, line|
            _, key, value = *line.match(/^(.*?):(.*?)(\r?\n)*$/)
            memo[key] = value == "NONE" ? nil : value
            memo
          end

          # Replace body tags to parse it with Nokogiri
          body.gsub!(/>\s+</m, '><')
          body.gsub!(/\s+</m, '<')
          body.gsub!(/>\s+/m, '>')
          body.gsub!(/<(\w+?)>([^<]+)/m, '<\1>\2</\1>')

          [headers, body]
        end
    end
  end
end
