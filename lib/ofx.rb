require "open-uri"

begin
  require "nokogiri"
rescue LoadError => e
  require "rubygems"
  require "nokogiri"
end

require "ofx/parser"
require "ofx/parser/ofx102"
require "ofx/foundation"
require "ofx/balance"
require "ofx/account"
require "ofx/transaction"
require "ofx/version"

def OFX(path, &block)
  yield OFX::Parser::Base.new(path).parser
end
