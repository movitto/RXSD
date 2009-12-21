# Things that don't fit elsewhere
#
# Copyright (C) 2009 Mohammed Morsi <movitto@yahoo.com>
# See COPYING for the License of this software

# we make use of the activesupport inflector
require 'active_support'

# logger support
require 'logger'

module RXSD
    # Logger helper class
    class Logger
      private
        LOG_LEVEL = ::Logger::FATAL # FATAL ERROR WARN INFO DEBUG

        def self._instantiate_logger
           unless defined? @@logger
             @@logger = ::Logger.new(STDOUT)
             @@logger.level = LOG_LEVEL
           end 
        end 

      public
        def self.method_missing(method_id, *args)
           _instantiate_logger
           @@logger.send(method_id, args)
        end 
        def self.logger
           _instantiate_logger
           @@logger
        end
    end
end

class Module
  # add virtual method support
  def virtual(*methods)
    methods.each do |m|
      define_method(m) {
        raise VirtualMethodCalledError, m
      }
    end
  end

  # add helper method to define a class method on any class
  def class_method(method_name, &block)
    (class << self; self; end).instance_eval do
      define_method method_name, block
    end
  end
end

# read entire file into string
def File.read_all(path)
  File.open(path, 'rb') {|file| return file.read }
end

# write contents of file from string
def File.write(path, str)
  File.open(path, 'wb') {|file| file.write str }
end
