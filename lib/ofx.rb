require "open-uri"
require "nokogiri"

require "ofx/errors"
require "ofx/parser"
require "ofx/parser/ofx102"
require "ofx/foundation"
require "ofx/balance"
require "ofx/account"
require "ofx/transaction"
require "ofx/version"

def OFX(resource, &block)
  yield OFX::Parser::Base.new(resource).parser
end
