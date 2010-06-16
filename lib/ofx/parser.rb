require "iconv"
require "kconv"

module OFX
  module Parser
    class Base
      attr_reader :headers
      attr_reader :body
      attr_reader :content
      attr_reader :parser

      def initialize(resource)
          resource = open_resource(resource)
          resource.rewind
          @content = convert_to_utf8(resource.read)

        begin
          @headers, @body = prepare(content)
        rescue Exception
          raise OFX::UnsupportedFileError
        end


        case @headers["VERSION"]
        when "102" then
          @parser = OFX::Parser::OFX102.new(:headers => headers, :body => body)
        else
          raise OFX::UnsupportedFileError
        end
      end

      def open_resource(resource)
        if resource.respond_to?(:read)
          return resource
        else
          begin
            return open(resource)
          rescue
            return StringIO.new(resource)
          end
        end
      end

      private
        def prepare(content)
          # Split headers & body
          headers, body = content.dup.split(/<OFX>/, 2)

          # Change single CR's to LF's to avoid issues with some banks
          headers.gsub!(/\r(?!\n)/, "\n") 

          raise OFX::UnsupportedFileError unless body

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
        
        def convert_to_utf8(string)
          return string if Kconv.isutf8(string)
          Iconv.conv('UTF-8', 'LATIN1//IGNORE', string) 
        end
    end
  end
end