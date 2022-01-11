# frozen_string_literal: true

=begin
  Yay. A
  multi
  line
  comment
=end
require 'pp'

# A super nice test module
module TestModule
  # Do nothing.
  def noop
    true
  end
end

# A testing class.
class FirstTestClass
  include TestModule

  # Do nothing, even better.
  def noop!
    [true, true]
  end
end

# Another class.
class TestClass < FirstTestClass
end

pp TestClass.new.noop, TestClass.new.noop!
