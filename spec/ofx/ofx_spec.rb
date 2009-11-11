require "spec/spec_helper"

describe OFX do
  describe "#OFX" do
    it "should yield an OFX instance" do
      OFX("spec/fixtures/sample.ofx") do |ofx|
        ofx.should be_kind_of(OFX::Parser::OFX102)
      end
    end
  end
end