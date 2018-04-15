RSpec.describe Resin::User do
  include FakeFS::SpecHelpers

  it "should allow registration" do

    VCR.use_cassette("auth/register") do
      auth = Resin::User.new
      auth.register "brfzei+dk2sdrq9ka464@grr.la", "brfzei+dk2sdrq9ka464"
    end
  end


  context "with valid credentials" do
    it "should be possible to login successfully" do
      VCR.use_cassette("auth/login") do
        auth = Resin::User.new
        expect {auth.login 'brfzei+dk2sdrq9ka464@grr.la', "brfzei+dk2sdrq9ka464"}.not_to raise_error
      end
    end
  end


  context "with invalid credentials" do
    it "should not be possible to login successfully" do
      VCR.use_cassette("auth/invalid_login") do
        auth = Resin::User.new
        expect {auth.login 'brfzei+dk2sdrq9ka464@grr.la', "brfzei+dk2sdrq9ka4641"}.to raise_error HTTParty::ResponseError
      end
    end
  end


end
