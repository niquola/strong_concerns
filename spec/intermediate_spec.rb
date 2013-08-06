require 'spec_helper'
describe StrongConcerns::Intermediate do
  class A
    def meth
      "ups"
    end
  end

  module B
    def self.require_methods
      %w[meth]
    end

    def decorated_meth
      "#{meth}#{options[:opt1]}"
    end
  end

  subject do
    obj = A.new
    kls = described_class.prepare(B)
    kls.new(obj, opt1: '!!!')
  end

  it "should turn of/on" do
    subject.should_not be_active
    subject.activate
    subject.should be_active
    subject.inactivate
    subject.should be_inactive
  end

  it "should delegate methods" do
    subject.meth.should == 'ups'
  end

  it "should call role methods" do
    subject.decorated_meth.should == 'ups!!!'
  end
end
