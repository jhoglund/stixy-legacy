require File.dirname(__FILE__) + '/../test_helper'
require "#{RAILS_ROOT}/vendor/plugins/backgroundrb/backgroundrb.rb"
require "#{RAILS_ROOT}/lib/workers/todo_notify_worker"
require 'drb'

class TodoNotifyWorkerTest < Test::Unit::TestCase

  # Replace this with your real tests.
  def test_truth
    #assert TodoNotifyWorker.included_modules.include?(DRbUndumped)
  end
end
