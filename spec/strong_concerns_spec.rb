require 'spec_helper'
require 'date'

describe StrongConcerns do
  module FullNamed
    def self.require_methods
      %w[first_name last_name]
    end

    def full_name
      "#{first_name} #{last_name}"
    end
  end

  module Old
    def self.require_methods
      %w[bith_date]
    end

    def age
      ((Date.today - bith_date)/365.0).to_i
    end

    def young?
      age < options[:young]
    end

    def reproductive?
      (options[:young]..options[:old]).include?(age)
    end

    def old?
      age > options[:old]
    end

    #should raise
    def breaking
      first_name
    end
  end

  module Searchable
    def self.require_methods
      %w[all]
    end

    def find_by_name(name)
      all.select {|item| item.first_name =~ /#{name}/}
    end
  end

  class Person < Struct.new(:first_name, :last_name, :bith_date)

    def self.all
      [ new('nicola','rhyzhikov', 33), new('ivan','ivanov', 33) ]
    end

    extend StrongConcerns

    class_concern Searchable,
      exports_methods: %w[find_by_name]

    concern Old,
      exports_methods: %w[age young? reproductive? breaking],
      young: 14, old: 70

    concern FullNamed,
      exports_methods: %w[full_name]

  end

  example do
    nicola = Person.new('nicola', 'rhyzhikov', Date.parse('1980-03-05'))

    -> {
      nicola.full_name
    }.should raise_error(StrongConcerns::RoleNotActive)

    nicola.as(FullNamed)

    nicola.full_name.should == "nicola rhyzhikov"

    nicola.as(Old)
    nicola.should_not be_young
    nicola.should be_reproductive

    -> {
      nicola.breaking
    }.should raise_error(/not list method/)
  end

  it "class_concern" do
    -> {
      Person
      .find_by_name('nicola')
      .should_not be_empty
    }.should raise_error(StrongConcerns::RoleNotActive)

    Person
    .as(Searchable)
    .find_by_name('nicola')
    .should_not be_empty

    -> {
      Person.find_by_name('nicola')
    }.should raise_error(StrongConcerns::RoleNotActive)
  end
end
