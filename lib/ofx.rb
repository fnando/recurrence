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
  parser = OFX::Parser::Base.new(resource).parser

  if block.arity == 1
    yield parser
  else
    parser.instance_eval(&block)
  end
end
