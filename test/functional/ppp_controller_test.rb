require File.dirname(__FILE__) + '/../test_helper'
require 'ppp_controller'

# Re-raise errors caught by the controller.
class PppController; def rescue_action(e) raise e end; end

class PppControllerTest < Test::Unit::TestCase
  def setup
    @controller = PppController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
