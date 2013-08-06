require 'spec_helper'

module Passworded
  def self.require_methods
    %w[password password_confirmation auth_source generate_password?]
  end

  def update_hashed_password
    if self.password && self.auth_source.blank?
      salt_password(password)
    end
  end

  def check_password?(clear_password)
    if auth_source_id.present?
      auth_source.authenticate(self.login, clear_password)
    else
      hash_password("#{salt}#{hash_password clear_password}") == hashed_password
    end
  end

  def change_password_allowed?
    return true if auth_source.nil?
    return auth_source.allow_password_changes?
  end

  def generate_password_if_needed
    if generate_password? && auth_source.nil?
      length = [Setting.password_min_length.to_i + 2, 10].max
      random_password(length)
    end
  end

  private

  def random_password(length=40)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    chars -= %w(0 O 1 l)
    password = ''
    length.times {|i| password << chars[SecureRandom.random_number(chars.size)] }
    self.password = password
    self.password_confirmation = password
    self
  end

  # Generates a random salt and computes hashed_password for +clear_password+
  # The hashed password is stored in the following form: SHA1(salt + SHA1(password))
  def salt_password(clear_password)
    self.salt = generate_salt
    self.hashed_password = hash_password("#{salt}#{hash_password clear_password}")
  end

  def hash_password(clear_password)
    Digest::SHA1.hexdigest(clear_password || "")
  end

  def generate_salt
    Redmine::Utils.random_hex(16)
  end
end

class User < Struct.new(:password, :password_confirmation)

  extend StrongConcerns

  concern Passworded,
    exports_methods: %w[
    update_hashed_password?
    check_password
  ]
end

describe StrongConcerns do
  let(:user) do
    Object.new.tap do |user|
      user.stub(:is_or_belongs_to?) { true }
    end
  end

  example do
    user = User.new('pass','confirmation')
    user.as(Passworded)
    user.update_hashed_password?

  end
end
