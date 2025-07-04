#!/usr/bin/env ruby

require 'rubygems'
require 'daemons'

options = {:dir_mode => :normal, :dir=> '/data/stixy/pids', :multiple => false, :backtrace => true, :monitor => false, :log_output => '../../log'}
Daemons.run(File.expand_path('todo_notify.rb', File.dirname(__FILE__)), options)