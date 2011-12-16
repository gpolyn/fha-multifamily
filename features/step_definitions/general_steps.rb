World(Rack::Test::Methods)

Given /^I send and accept json$/ do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
end

Given /^I have this (?:json|xml) .*? data$/ do |data|
  @data = replace_placeholders(data)
end

When /^I send a POST request with the (\w+) data to (.*)$/ do |type,url|
  request_page(url_for_test(url), :post, @data)
end

def replace_placeholders(data, mode = :json)
  data = data.to_s
  
  # Do we need to replace any evals? i.e. [@customer.id]
  re = /\[@([^\]]*)\]/
  while data =~ re
    Rails.logger.debug "Eval'ing data (#{data.inspect})"
    replacement = eval("@#{$1}")
    data.sub! re, replacement.nil? ? '' : replacement.to_s
  end
  
  # Replace `your value` and `auto generated` with null
  re = /(`your value`|`auto generated`)/
  null = (mode == :json) ? 'null' : ''
  while data =~ re
    data.sub! re, null
  end
  
  data
end