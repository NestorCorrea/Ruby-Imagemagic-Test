require 'test_helper'

class ImageProessControllerTest < ActionController::TestCase
  test "should get process_image_1" do
    get :process_image_1
    assert_response :success
  end

end
