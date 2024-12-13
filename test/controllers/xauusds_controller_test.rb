require "test_helper"

class XauusdsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @xauusd = xauusds(:one)
  end

  test "should get index" do
    get xauusds_url
    assert_response :success
  end

  test "should get new" do
    get new_xauusd_url
    assert_response :success
  end

  test "should create xauusd" do
    assert_difference("Xauusd.count") do
      post xauusds_url, params: { xauusd: { close: @xauusd.close, date: @xauusd.date, high: @xauusd.high, low: @xauusd.low, open: @xauusd.open, timestamp: @xauusd.timestamp, volume: @xauusd.volume } }
    end

    assert_redirected_to xauusd_url(Xauusd.last)
  end

  test "should show xauusd" do
    get xauusd_url(@xauusd)
    assert_response :success
  end

  test "should get edit" do
    get edit_xauusd_url(@xauusd)
    assert_response :success
  end

  test "should update xauusd" do
    patch xauusd_url(@xauusd), params: { xauusd: { close: @xauusd.close, date: @xauusd.date, high: @xauusd.high, low: @xauusd.low, open: @xauusd.open, timestamp: @xauusd.timestamp, volume: @xauusd.volume } }
    assert_redirected_to xauusd_url(@xauusd)
  end

  test "should destroy xauusd" do
    assert_difference("Xauusd.count", -1) do
      delete xauusd_url(@xauusd)
    end

    assert_redirected_to xauusds_url
  end
end
