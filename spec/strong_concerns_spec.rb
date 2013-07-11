require 'spec_helper'

describe StrongConcerns do
  module FullNamed
    def full_name
      "#{first_name} #{last_name}"
    end
  end

  module AgeAssertions
    def young?
      age < options[:young]
    end

    def reproductive?
      (options[:young]..options[:old]).include?(age)
    end

    def old?
      age > options[:old]
    end
  end

  class Person

    attr :first_name
    attr :last_name
    attr :age

    def initialize(first_name, last_name, age)
      @first_name = first_name
      @last_name = last_name
      @age = age
    end


    extend StrongConcerns

    concern AgeAssertions,
      require_methods: %w[age],
      exports_methods: %w[young? reproductive?],
      young: 14, old: 70

    concern FullNamed,
      require_methods: %w[first_name last_name],
      exports_methods: %w[full_name]

  end

  example do
    Person.new('nicola', 'rhyzhikov', 33).tap do |nicola|
      nicola.full_name.should == "nicola rhyzhikov"
      nicola.should_not be_young
      nicola.should be_reproductive
    end
  end
end
