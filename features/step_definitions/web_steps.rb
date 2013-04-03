module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

Given /^(?:|I )am on "(.+)"$/ do |page_name|
  visit path_to(page_name)
end

Given /^(?:|I )am on (the .+ page)(?: with params "([^"]*)")?$/ do |page_name, params|
  visit params ? path_to(page_name, eval(params)) : path_to(page_name)
end

When /^(?:|I )follow "([^"]*)"(?: within "([^"]*)")?$/ do |link, selector| 
  with_scope(selector) do
    click_link(link)
  end
end

When /^(?:|I )follow list item "([^"]*)"(?: within "([^"]*)")?$/ do |link, selector| 
  with_scope(selector) do
    all(:link, link).first.click
  end
end

When /^I click locator "([^"]*)"$/ do |locator|
  find(:xpath, "//*[contains(concat(' ', normalize-space(@class), ' '), ' #{locator} ')]").click
end


When /^(?:|I )fill in "([^"]*)" with tomorrow(?: within "([^"]*)")?$/ do |field, selector|
  with_scope(selector) do
    fill_in(field, :with => Date.tomorrow.strftime('%Y-%m-%d'))
  end
end

When /^(?:|I )fill in "([^"]*)" with "([^"]*)"(?: within "([^"]*)")?$/ do |field, value, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end

When /^(?:|I )fill in "([^"]*)" with$/ do |field, multiline|
  fill_in(field, :with => multiline)
end

When /^(?:|I )fill in "([^"]*)" for "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
  end
end

# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select og option
# based on naming conventions.
#
When /^(?:|I )fill in the following(?: within "([^"]*)")?:$/ do |selector, fields|
  with_scope(selector) do
    fields.rows_hash.each do |name, value|
      When %{I fill in "#{name}" with "#{value}"}
    end
  end
end

When /^(?:|I )press "([^"]*)"(?: within "([^"]*)")?$/ do |button, selector|
  with_scope(selector) do
    click_button(button)
  end
end

When /^(?:|I )select( localized)? "([^"]*)" from "([^"]*)"(?: within "([^"]*)")?$/ do |localized, value, field, selector|
  value = I18n.t( value ) if localized

  with_scope(selector) do
    select(value, :from => field)
  end
end


Then /^(?:|I )should see "([^"]*)"(?: within( any)? "([^"]*)")?$/ do |text, any, selector|
  if any
    if selector
      if page.respond_to? :should
        page.should have_css(selector, :text => text)
      else
        assert page.has_css(selector, :text => text)
      end
    else
      if page.respond_to? :should
        page.should have_content(text)
      else
        assert page.has_content?(text)
      end
    end
  else
    with_scope(selector) do
      if page.respond_to? :should
        page.should have_content(text)
      else
        assert page.has_content?(text)
      end
    end
  end
end

Then /^(?:|I )should not see "([^"]*)"(?: within( any)? "([^"]*)")?$/ do |text, any, selector|
  if any
    if selector
      if page.respond_to? :should
        page.should_not have_css(selector, :text => text)
      else
        assert page.has_no_css(selector, :text => text)
      end
    else
      if page.respond_to? :should
        page.should_not have_content(text)
      else
        assert page.has_no_content?(text)
      end
    end
  else
    with_scope(selector) do
      if page.respond_to? :should
        page.should have_no_content(text)
      else
        assert page.has_no_content?(text)
      end
    end
  end
end
