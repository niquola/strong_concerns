module StrongConcerns
  class Role
    attr  :mod

    def initialize(mod, options)
      @mod = mod
      @options = options
    end

    def intermediate_class
      @intermediate_class ||= Intermediate.prepare(@mod)
    end

    def instance(subject)
      intermediate_class.new(subject, @options)
    end
  end

  module Reflection
    def add_class_role(mod, options)
      self.class_roles[mod] = Role.new(mod, options)
    end

    def add_instance_role(mod, options)
      self.instance_roles[mod] = Role.new(mod, options)
    end

    def find_instance_role(mod)
      instance_roles[mod]
    end

    def find_class_role(mod)
      class_roles[mod]
    end

    def instance_roles
      @instance_roles ||= {}
    end

    def class_roles
      @class_roles ||= {}
    end
  end
end
