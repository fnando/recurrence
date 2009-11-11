require "spec/spec_helper"

describe OFX::Parser::OFX102 do
  before do
    @ofx = OFX::Parser::Base.new("spec/fixtures/sample.ofx")
    @parser = @ofx.parser
  end
  
  it "should have a version" do
    OFX::Parser::OFX102::VERSION.should == "1.0.2"
  end
  
  it "should set headers" do
    @parser.headers.should == @ofx.headers
  end
  
  it "should set body" do
    @parser.body.should == @ofx.body
  end
  
  it "should set account" do
    @parser.account.should be_a_kind_of(OFX::Account)
  end
end