# tests the loader module
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

class LoaderTest < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_load_file
     File.write("/tmp/rxsd-test", "foobar")
     data = RXSD::Loader.load("file:///tmp/rxsd-test")
     assert_equal "foobar", data
  end
end
