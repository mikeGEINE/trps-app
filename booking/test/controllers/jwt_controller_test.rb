require 'test_helper'

class JwtControllerTest < ActionDispatch::IntegrationTest
  test "should get acs" do
    get jwt_acs_url
    assert_response :success
  end

  test "should get logout" do
    get jwt_logout_url
    assert_response :success
  end

end
