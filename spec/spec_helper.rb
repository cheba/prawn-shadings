# encoding: utf-8

puts "prawn-shadings specs: Running on Ruby Version: #{RUBY_VERSION}"

require "bundler"
Bundler.setup

require "prawn"

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

Prawn.debug = true

require 'prawn/shadings'

require "rspec"
require "pdf/reader"
require "pdf/inspector"

def create_pdf(klass=Prawn::Document)
  @pdf = klass.new(:margin => 0)
end
