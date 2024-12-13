require "test_helper"

class BtcsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @btc = btcs(:one)
  end

  test "should get index" do
    get btcs_url
    assert_response :success
  end

  test "should get new" do
    get new_btc_url
    assert_response :success
  end

  test "should create btc" do
    assert_difference("Btc.count") do
      post btcs_url, params: { btc: { close: @btc.close, date: @btc.date, high: @btc.high, low: @btc.low, open: @btc.open, timestamp: @btc.timestamp, volume: @btc.volume } }
    end

    assert_redirected_to btc_url(Btc.last)
  end

  test "should show btc" do
    get btc_url(@btc)
    assert_response :success
  end

  test "should get edit" do
    get edit_btc_url(@btc)
    assert_response :success
  end

  test "should update btc" do
    patch btc_url(@btc), params: { btc: { close: @btc.close, date: @btc.date, high: @btc.high, low: @btc.low, open: @btc.open, timestamp: @btc.timestamp, volume: @btc.volume } }
    assert_redirected_to btc_url(@btc)
  end

  test "should destroy btc" do
    assert_difference("Btc.count", -1) do
      delete btc_url(@btc)
    end

    assert_redirected_to btcs_url
  end
end
