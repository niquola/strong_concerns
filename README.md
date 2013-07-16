# StrongConcerns

Concerns is powerfull method of object decomposition:

http://37signals.com/svn/posts/3372-put-chubby-models-on-a-diet-with-concerns

But this pattern is easilly can be abused:
  when you just spliting object behavior physicaly, not logicaly, you've got messy code.

The core point is tracking the internal interface between an object and a concern!
Minimal & explicit interface forward you to craft more clean and reusable concerns.
The ideal concern is ruby's Enumerable, which require only one method to be implemented in hosting class.

Gem **strong_concerns** is technically helping you to create concerns in a right way.

## Installation

Add this line to your application's Gemfile:

    gem 'strong_concerns'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install strong_concerns

## Usage

``` ruby

module AgeAssertions

  # list methods required for concern
  def self.require_methods
    %w[age]
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
end

module Searchable
  def self.require_methods
    %w[all]
  end

  def find_by_name(name)
    all.select {|item| item.first_name =~ /#{name}/}
  end
end

class Person

  attr :age
  attr :name

  def self.all
    [new('nicola', 33), new('ivan', 33)]
  end

  def initialize( name, age)
    @name, @age = name, age
  end

  extend StrongConcerns

  concern AgeAssertions,
    exports_methods: %w[young? reproductive?],
    old: 70,
    young: 14

  class_concern Searchable,
    exports_methods: %w[find_by_name]
end

nicola = Person.new('nicola', 33)
if nicola.reproductive?
  puts "Cool, make me a child!"
end

Person.find_by_name('nicola') #=> Person(name: 'nicola')
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
