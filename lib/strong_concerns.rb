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

  def class_concern(mod, options)
    intermidiate_class = prepare_intermidiate(mod)
    options.fetch(:exports_methods).each do |meth|
      self.define_singleton_method meth do |*args, &block|
	((@__strong_concerns ||= {})[mod.to_s] ||= intermidiate_class.new(self, options)).send(meth,*args, &block)
      end
    end
  end

  def concern(mod, options)
    intermidiate_class = prepare_intermidiate(mod)
    options.fetch(:exports_methods).each do |meth|
      self.send(:define_method, meth) do |*args, &block|
	((@__strong_concerns ||= {})[mod.to_s] ||= intermidiate_class.new(self, options)).send(meth,*args, &block)
      end
    end
  end

  private

  def prepare_intermidiate(mod)
    Class.new(Intermidiate).tap do |kls|
      kls.send(:include, mod)
      meths = mod.require_methods
      kls.def_delegators :@__subject, *meths
    end
  end
end
