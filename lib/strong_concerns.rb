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

  def class_concern(mod, options)
    intermediate_class = prepare_intermediate(mod)
    options.fetch(:exports_methods).each do |meth|
      self.define_singleton_method meth do |*args, &block|
	((@__strong_concerns ||= {})[mod.to_s] ||= intermediate_class.new(self, options)).send(meth,*args, &block)
      end
    end
  end

  def concern(mod, options)
    intermediate_class = prepare_intermediate(mod)
    options.fetch(:exports_methods).each do |meth|
      self.send(:define_method, meth) do |*args, &block|
	((@__strong_concerns ||= {})[mod.to_s] ||= intermediate_class.new(self, options)).send(meth,*args, &block)
      end
    end
  end

  private

  def prepare_intermediate(mod)
    Class.new(Intermediate).tap do |kls|
      kls.send(:include, mod)
      meths = mod.require_methods
      kls.def_delegators :@__subject, *meths
    end
  end
end
