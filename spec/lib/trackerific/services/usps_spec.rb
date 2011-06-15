require 'spec_helper'
require 'fakeweb'

USPS_TRACK_URL = %r|http://testing\.shippingapis\.com/.*|

describe Trackerific::USPS do
  include Fixtures
  
  describe :required_options do
    subject { Trackerific::USPS.required_options }
    it { should include(:user_id) }
  end
  
  describe :package_id_matchers do
    subject { Trackerific::UPS.package_id_matchers }
    it("should be an Array of Regexp") { should each { |m| m.should be_a Regexp } }
  end
  
  describe :track_package do
    
    before(:all) do
      @package_id = 'EJ958083578US'
      @usps = Trackerific::USPS.new :user_id => '123USERID4567'
    end
    
    context "with a successful response from the server" do
      
      before(:all) do
        FakeWeb.register_uri(:get, USPS_TRACK_URL, :body => load_fixture(:usps_success_response))
      end
      
      before(:each) do
        @tracking = @usps.track_package(@package_id)
      end
      
      subject { @tracking }
      it("should return a Trackerific::Details") { should be_a Trackerific::Details }
      
      describe "events.length" do
        subject { @tracking.events.length }
        it { should >= 1 }
      end
      
      describe :summary do
        subject { @tracking.summary }
        it { should_not be_empty }
      end
      
    end
    
    context "with an error response from the server" do
      
      before(:all) do
        FakeWeb.register_uri(:get, USPS_TRACK_URL, :body => load_fixture(:usps_error_response))
      end
      
      specify { lambda { @usps.track_package(@package_id) }.should raise_error(Trackerific::Error) }
      
    end
  end
    
end
