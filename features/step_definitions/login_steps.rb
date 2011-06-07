Given /^a user with email "([^"]*)" and password "([^"]*)"$/ do |email, password|
  User.create!(:email => email, :password => password, :password_confirmation => password)
end
