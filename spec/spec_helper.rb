# coding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'simplecov'

#RSpec.configure do |config|
#end

SimpleCov.start do
  add_filter '/spec/'
end