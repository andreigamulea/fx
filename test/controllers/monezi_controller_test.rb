require "test_helper"

class MoneziControllerTest < ActionDispatch::IntegrationTest
  test "should get us30" do
    get monezi_us30_url
    assert_response :success
  end
end
