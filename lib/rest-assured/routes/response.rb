module RestAssured
  class Response

    def self.perform(app)
      request = app.request

      matching_doubles = Models::Double.where(:fullpath => request.fullpath, :verb => request.request_method)

      if matching_doubles.any?
        doubles_with_request_headers = matching_doubles.select {|m| m.request_headers.any?}

        if d = find_double_that_matches_request(app, doubles_with_request_headers)
          return_double app, d
        else
          return_double app, matching_doubles.find {|m| m.active}
        end
      elsif redirect_url = Models::Redirect.find_redirect_url_for(request.fullpath)
        if d = Models::Double.where(:fullpath => redirect_url, :active => true, :verb => request.request_method).first
          return_double app, d
        else
          app.redirect redirect_url
        end
      else
        app.status 404
      end
    end

    def self.find_double_that_matches_request app, doubles
      doubles.find do |double|
        result = double.request_headers.all? { |h|
          expected_header_name = "HTTP_#{h.name.gsub("-", "_").upcase}"
          app.env[expected_header_name] == h.value
        }
      end
    end

    def self.return_double(app, d)
      request = app.request
      request.body.rewind
      body = request.body.read #without temp variable ':body = > body' is always nil. mistery
      env  = request.env.except('rack.input', 'rack.errors', 'rack.logger')

      d.requests.create!(:rack_env => env.to_json, :body => body, :params => request.params.to_json)

      app.headers d.response_headers
      app.body d.content
      app.status d.status
    end

  end
end
