require "test_helper"

class Us30sControllerTest < ActionDispatch::IntegrationTest
  setup do
    @us30 = us30s(:one)
  end

  test "should get index" do
    get us30s_url
    assert_response :success
  end

  test "should get new" do
    get new_us30_url
    assert_response :success
  end

  test "should create us30" do
    assert_difference("Us30.count") do
      post us30s_url, params: { us30: { close: @us30.close, date: @us30.date, high: @us30.high, low: @us30.low, open: @us30.open, timestamp: @us30.timestamp, volume: @us30.volume } }
    end

    assert_redirected_to us30_url(Us30.last)
  end

  test "should show us30" do
    get us30_url(@us30)
    assert_response :success
  end

  test "should get edit" do
    get edit_us30_url(@us30)
    assert_response :success
  end

  test "should update us30" do
    patch us30_url(@us30), params: { us30: { close: @us30.close, date: @us30.date, high: @us30.high, low: @us30.low, open: @us30.open, timestamp: @us30.timestamp, volume: @us30.volume } }
    assert_redirected_to us30_url(@us30)
  end

  test "should destroy us30" do
    assert_difference("Us30.count", -1) do
      delete us30_url(@us30)
    end

    assert_redirected_to us30s_url
  end
end
