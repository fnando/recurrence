require "spec/spec_helper"

describe OFX do
  describe "#OFX" do
    it "should yield an OFX instance" do
      OFX("spec/fixtures/sample.ofx") do |ofx|
        ofx.class.should == OFX::Parser::OFX102
      end
    end

    it "should be an OFX instance" do
      OFX("spec/fixtures/sample.ofx") do
        self.class.should == OFX::Parser::OFX102
      end
    end

    it "should return parser" do
      OFX("spec/fixtures/sample.ofx").class.should == OFX::Parser::OFX102
    end
  end
end
