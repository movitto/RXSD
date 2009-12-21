# rxsd types tests
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

class TypesTest < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_string_to_from
     assert "true".to_b
     assert !"false".to_b
     assert_raises ArgumentError do
        "foobar".to_b
     end

     assert_equal "money", String.from_s("money")
  end

  def test_boolean_to_from
     assert Boolean.from_s("true")
     assert !Boolean.from_s("false")
  end

  def test_char_to_from
     assert_equal "c", Char.from_s("c")
  end

  def test_int_to_from
     assert_equal 123,  Integer.from_s("123")
  end

  def test_float_to_from
     assert_equal 4.25,  Float.from_s("4.25")
  end

  def test_array_to_from
     arr = Array.from_s "4 9 50 123", Integer
     assert_equal 4, arr.size
     assert arr.include?(4)
     assert arr.include?(9)
     assert arr.include?(50)
     assert arr.include?(123)
  end
end
