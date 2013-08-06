require 'forwardable'

# two way proxy
module StrongConcerns
  class Intermediate
    extend Forwardable

    def self.prepare(mod)
      Class.new(Intermediate).tap do |kls|
	kls.send(:include, mod)
	meths = mod.require_methods
	kls.def_delegators :@__subject__, *meths
      end
    end

    attr_accessor :options

    def activate
      @active = true
    end

    def inactivate
      @active = false
    end

    def active?
      @active
    end

    def inactive?
      not active?
    end

    def initialize(subject, options)
      @__subject__ = subject
      @options = options
      @active = false
    end

    def method_missing(meth)
      raise NameError.new("Looks like you not list method <#{meth}> in self.require_methods of concern or misspelled it")
    end

    def inspect
      "Intermediate<#{self.methods}>"
    end
  end
end
