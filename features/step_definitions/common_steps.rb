When /^I fill datepicker "([^"]*)" with "([^"]*)"$/ do |selector, value|
  page.execute_script "jQuery('##{selector}').val('#{value}');"
end

When /^I wait until all Ajax requests are complete$/ do
  unless page.evaluate_script('typeof(jQuery)') == 'undefined'
    start_time = Time.now
    page.evaluate_script('jQuery.isReady&&jQuery.active==0').class.should_not eql(String) until page.evaluate_script('jQuery.isReady&&jQuery.active==0') or (start_time + 5.seconds) < Time.now do
      sleep 1
    end
  end
end

When /^I browse full screen$/ do
  page.driver.browser.manage.window.resize_to(1350,1200)
end

When /I am on current common user "([^\"]*)" edit page$/ do |model|
  @current_user.reload if @current_user.send(model).empty?
  step %Q{I am on the edit company page with params "{ :id => @current_user.#{model}.id }"}
end

When /I am on current common user (\d+). "([^\"]*)" edit page$/ do |nth, model|
  @current_user.reload if @current_user.send(model.pluralize).empty?
  step %Q{I am on the edit #{model} page with params "{ :id => @current_user.#{model.pluralize}[#{nth.to_i - 1}].id }"}
end
