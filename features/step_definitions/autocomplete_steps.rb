When /^(?:|I )fill in "([^"]*)" autocomplete with "([^"]*)"(?: within "([^"]*)")?$/ do |field, value, selector|
  with_scope(selector) do
    fill_in(field, :with => value)
    sleep 3
    page.execute_script %Q{ jQuery('.ui-autocomplete-input').trigger("keydown") }
  end
end

When /^(?:|I )pick "([^"]*)" autocomplete option$/ do |selection|
  page.execute_script %Q{ jQuery('.ui-menu-item a:contains("#{selection}")').trigger("mouseenter").trigger("click"); }
end

Then /^(?:|I )should see (\d+) autocomplete suggestions$/ do |row_count|
  assert has_no_xpath?( "//*[text()='no existing match']")
  assert page.has_xpath?("//*[contains(@class, 'ui-menu-item')]", :count => row_count.to_i)
end

Then /^(?:|I )should see no autocomplete suggestions$/ do
  assert page.has_no_xpath?("//*[contains(@class, 'ui-menu-item')]")
end

When /^(?:|I )fill in "([^"]*)" account_segment_chooser with "([^"]*)"$/ do |field, value|
  page.execute_script %Q{ $('##{field}').trigger("focus").trigger("mouseenter").trigger("click");}
end
