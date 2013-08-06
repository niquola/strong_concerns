require 'spec_helper'
describe StrongConcerns::Reflection do
  class A
    extend StrongConcerns::Reflection
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

  subject { A }

  it "instance roles" do
    subject.instance_roles.should be_empty
    subject.add_instance_role(B, opt1: 'val1')
    role = subject.find_instance_role(B)
    role.should be_a(StrongConcerns::Role)
  end

  it "class roles" do
    subject.class_roles.should be_empty
    subject.add_class_role(B, opt1: 'val1')
    role = subject.find_class_role(B)
    role.should be_a(StrongConcerns::Role)
  end
end
