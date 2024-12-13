require "application_system_test_case"

class Us30sTest < ApplicationSystemTestCase
  setup do
    @us30 = us30s(:one)
  end

  test "visiting the index" do
    visit us30s_url
    assert_selector "h1", text: "Us30s"
  end

  test "should create us30" do
    visit us30s_url
    click_on "New us30"

    fill_in "Close", with: @us30.close
    fill_in "Date", with: @us30.date
    fill_in "High", with: @us30.high
    fill_in "Low", with: @us30.low
    fill_in "Open", with: @us30.open
    fill_in "Timestamp", with: @us30.timestamp
    fill_in "Volume", with: @us30.volume
    click_on "Create Us30"

    assert_text "Us30 was successfully created"
    click_on "Back"
  end

  test "should update Us30" do
    visit us30_url(@us30)
    click_on "Edit this us30", match: :first

    fill_in "Close", with: @us30.close
    fill_in "Date", with: @us30.date
    fill_in "High", with: @us30.high
    fill_in "Low", with: @us30.low
    fill_in "Open", with: @us30.open
    fill_in "Timestamp", with: @us30.timestamp
    fill_in "Volume", with: @us30.volume
    click_on "Update Us30"

    assert_text "Us30 was successfully updated"
    click_on "Back"
  end

  test "should destroy Us30" do
    visit us30_url(@us30)
    click_on "Destroy this us30", match: :first

    assert_text "Us30 was successfully destroyed"
  end
end
