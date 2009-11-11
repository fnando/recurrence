require "rubygems"
require "spec"

$LOAD_PATH.unshift File.dirname(__FILE__) + "/../lib"

require "ofx"

Spec::Matchers.define :have_key do |key|
  match do |hash|
    hash.respond_to?(:keys) && 
    hash.keys.kind_of?(Array) &&
    hash.keys.include?(key)
  end
end