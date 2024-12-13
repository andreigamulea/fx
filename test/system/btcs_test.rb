require "application_system_test_case"

class BtcsTest < ApplicationSystemTestCase
  setup do
    @btc = btcs(:one)
  end

  test "visiting the index" do
    visit btcs_url
    assert_selector "h1", text: "Btcs"
  end

  test "should create btc" do
    visit btcs_url
    click_on "New btc"

    fill_in "Close", with: @btc.close
    fill_in "Date", with: @btc.date
    fill_in "High", with: @btc.high
    fill_in "Low", with: @btc.low
    fill_in "Open", with: @btc.open
    fill_in "Timestamp", with: @btc.timestamp
    fill_in "Volume", with: @btc.volume
    click_on "Create Btc"

    assert_text "Btc was successfully created"
    click_on "Back"
  end

  test "should update Btc" do
    visit btc_url(@btc)
    click_on "Edit this btc", match: :first

    fill_in "Close", with: @btc.close
    fill_in "Date", with: @btc.date
    fill_in "High", with: @btc.high
    fill_in "Low", with: @btc.low
    fill_in "Open", with: @btc.open
    fill_in "Timestamp", with: @btc.timestamp
    fill_in "Volume", with: @btc.volume
    click_on "Update Btc"

    assert_text "Btc was successfully updated"
    click_on "Back"
  end

  test "should destroy Btc" do
    visit btc_url(@btc)
    click_on "Destroy this btc", match: :first

    assert_text "Btc was successfully destroyed"
  end
end
