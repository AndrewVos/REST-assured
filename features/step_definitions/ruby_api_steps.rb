Given /^rest\-assured server is not running$/ do
end

When /^I start rest\-assured server via client library$/ do
  @server = RestAssured::Server.new
  @server.start
end

Then /^rest\-assured server should be running$/ do
  60.times do
    if `ps a | grep rest-assured`[/#{@server.port}/]
      break
    else
      sleep 1
    end
  end

  `ps a | grep rest-assured`[/#{@server.port}/].should_not be_nil
end
