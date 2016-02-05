require 'test_helper'

class SetLanguageControllerTest < ActionController::TestCase
  test "should get english" do
    get :english
    assert_response :success
  end

  test "should get russian" do
    get :russian
    assert_response :success
  end

end
