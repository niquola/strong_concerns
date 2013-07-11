require 'forwardable'
require "strong_concerns/version"

module StrongConcerns
  class Intermidiate
    extend Forwardable
    attr_accessor :options

    def initialize(subject, options)
      @__subject = subject
      @options = options
    end

    def inspect
      "Intermidiate<#{self.methods}>"
    end
  end

  def concern(mod, options)
    intermidiate_class = Class.new(Intermidiate)
    intermidiate_class.send(:include, mod)
    meths = options.fetch(:require_methods)
    intermidiate_class.def_delegators :@__subject, *meths

    options.fetch(:exports_methods).each do |meth|
      define_method meth do |*args, &block|
	((@__strong_concerns ||= {})[mod.to_s] ||= intermidiate_class.new(self, options)).send(meth,*args, &block)
      end
    end
  end
end
