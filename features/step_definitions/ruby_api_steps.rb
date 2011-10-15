Given /^rest\-assured server is not running$/ do
end

When /^I start rest\-assured server via client library$/ do
  @server_proc = RestAssured::Server.start
end

Then /^rest\-assured server should be running$/ do
  60.times do
    if `ps a | grep rest-assured`[/#{@server_proc.psname}/]
      break
    else
      sleep 1
    end
  end

  `ps a | grep rest-assured`[/#{@server_proc.psname}/].should_not be_nil
end
