require "application_system_test_case"

class XauusdsTest < ApplicationSystemTestCase
  setup do
    @xauusd = xauusds(:one)
  end

  test "visiting the index" do
    visit xauusds_url
    assert_selector "h1", text: "Xauusds"
  end

  test "should create xauusd" do
    visit xauusds_url
    click_on "New xauusd"

    fill_in "Close", with: @xauusd.close
    fill_in "Date", with: @xauusd.date
    fill_in "High", with: @xauusd.high
    fill_in "Low", with: @xauusd.low
    fill_in "Open", with: @xauusd.open
    fill_in "Timestamp", with: @xauusd.timestamp
    fill_in "Volume", with: @xauusd.volume
    click_on "Create Xauusd"

    assert_text "Xauusd was successfully created"
    click_on "Back"
  end

  test "should update Xauusd" do
    visit xauusd_url(@xauusd)
    click_on "Edit this xauusd", match: :first

    fill_in "Close", with: @xauusd.close
    fill_in "Date", with: @xauusd.date
    fill_in "High", with: @xauusd.high
    fill_in "Low", with: @xauusd.low
    fill_in "Open", with: @xauusd.open
    fill_in "Timestamp", with: @xauusd.timestamp
    fill_in "Volume", with: @xauusd.volume
    click_on "Update Xauusd"

    assert_text "Xauusd was successfully updated"
    click_on "Back"
  end

  test "should destroy Xauusd" do
    visit xauusd_url(@xauusd)
    click_on "Destroy this xauusd", match: :first

    assert_text "Xauusd was successfully destroyed"
  end
end
