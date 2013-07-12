require 'forwardable'
require "strong_concerns/version"

module StrongConcerns
  class Intermediate
    extend Forwardable
    attr_accessor :options

    def initialize(subject, options)
      @__subject = subject
      @options = options
    end

    def inspect
      "Intermediate<#{self.methods}>"
    end
  end

  def concern(mod, options)
    intermediate_class = Class.new(Intermediate)
    intermediate_class.send(:include, mod)
    meths = options.fetch(:require_methods)
    intermediate_class.def_delegators :@__subject, *meths

    options.fetch(:exports_methods).each do |meth|
      define_method meth do |*args, &block|
	((@__strong_concerns ||= {})[mod.to_s] ||= intermediate_class.new(self, options)).send(meth,*args, &block)
      end
    end
  end
end
