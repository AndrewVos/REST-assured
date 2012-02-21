require File.expand_path('../../spec_helper', __FILE__)

module RestAssured::Models
  describe RequestHeader do
    it { should allow_mass_assignment_of(:name)}
    it { should allow_mass_assignment_of(:value)}

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:value) }
  end
end
