module RestAssured
  module Models
    class RequestHeader < ActiveRecord::Base
      validates_presence_of :name
      validates_presence_of :value
    end
  end
end
