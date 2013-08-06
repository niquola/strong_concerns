$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
require "strong_concerns/version"

module StrongConcerns
  class RoleNotActive < StandardError; end

  autoload :Intermediate, 'strong_concerns/intermediate'
  autoload :Reflection, 'strong_concerns/reflection'

  module InstanceMethods
    def as(mod)
      role_instance(mod).activate
      self
    end

    def role_instances
      @role_instances ||= {}
    end

    def role_instance(mod)
      role_instances[mod] ||= self.class
      .find_instance_role(mod)
      .instance(self)
    end
  end

  def self.extended(base)
    base.send(:extend, Reflection)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)
    super
  end

  def concern(mod, options)
    self.add_instance_role(mod, options)
    options.fetch(:exports_methods).each do |meth|
      self.send(:define_method, meth) do |*args, &block|
	inter = role_instance(mod)
	unless inter.active?
	  raise RoleNotActive.new("Your call method <#{meth}> of inactive role <#{mod.name}>!")
	end
	inter.send(meth,*args, &block)
      end
    end
  end

  module ClassMethods
    def as(mod)
      role_instance(mod).activate
      self
    end

    def role_instances
      @role_instances ||= {}
    end

    def role_instance(mod)
      role_instances[mod] ||= self.find_class_role(mod).instance(self)
    end
  end

  def class_concern(mod, options)
    self.add_class_role(mod, options)
    options.fetch(:exports_methods).each do |meth|
      self.define_singleton_method meth do |*args, &block|
	inter = role_instance(mod)
	unless inter.active?
	  raise RoleNotActive.new("Your call method <#{meth}> of inactive role <#{mod.name}>!")
	end
	inter.inactivate
	inter.send(meth,*args, &block)
      end
    end
  end
end
