require_relative 'test_helper'
require 'capybara/rails'
require "active_support/test_case"

# require all integration helpers
Dir[File.dirname(__FILE__) + '/helpers/integration/*.rb'].each do |file|
  require file
end

class IntegrationTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include RecordTracking
  include ContentAssertions
  include PageAssertions
  include AccountManagement
  include UserRecords
  include PageRecords

  # included last so crashes in other extensions will get logged.
  include EnhancedLogging

  protected

  def setup
    Capybara.reset_sessions!
    super
  end

  # this is overwritten by JavascriptIntegrationTest.
  # RackTests run in the same process so we need to reset User.current
  def clear_session
    Capybara.reset_sessions!
    User.current = nil
  end

  def group
    records[:group] ||= FactoryGirl.create(:group)
  end

  #
  # Helper to combine several tests into one.
  #
  # It's sometimes cumbersome to test the same thing for say all page types
  # or a number of different users.
  # assert_for_all allows to run a block for a number of objects.
  # If an assertion fails it will add information about which object
  # it failed for.
  #
  def assert_for_all(one_or_many)
    if one_or_many.respond_to? :each
      one_or_many.each_with_index do |one, i|
        begin
          yield one
        rescue MiniTest::Assertion => e
          # preserve the backtrace but add the run number to the message
          message  = "#{$!} in run #{i+1} with #{one.class.name}"
          message += " #{one.to_s}" if one.respond_to? :to_s
          raise $!, message, $!.backtrace
        end
      end
    else
      yield one_or_many
    end
  end


end

