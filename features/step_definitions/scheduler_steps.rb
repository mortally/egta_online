When /^I add strategy "([^"]*)" to that game scheduler$/ do |arg1|
  @game_scheduler.add_strategy_by_name(arg1)
end

Then /^I should have (\d+) simulations? scheduled$/ do |arg1|
  Simulation.count.should == arg1.to_i
end

Then /^that simulation should have profile "([^"]*)"$/ do |arg1|
  @simulation = Simulation.first
  Profile.find(@simulation.profile_id).name.should == arg1
end

Then /^that simulation should have state "([^"]*)"$/ do |arg1|
  @simulation.state.should == arg1
end

Then /^all simulations should have state "([^"]*)"$/ do |arg1|
  Simulation.all.each { |sim| sim.state.should == "pending" }
end