RSpec.describe Resin::Modules::User do
  include FakeFS::SpecHelpers

  it 'should allow registration' do
    VCR.use_cassette('auth/register') do
      auth = Resin::Modules::User.new
      auth.register VALID_USER_EMAIL, VALID_USER_PASSWORD
    end
  end

  context 'with valid credentials' do
    it 'should be possible to login successfully' do
      VCR.use_cassette('auth/login') do
        auth = Resin::Modules::User.new
        expect {auth.login VALID_USER_EMAIL, VALID_USER_PASSWORD}.not_to raise_error
      end
    end
  end

  context 'with invalid credentials' do
    it 'should not be possible to login successfully' do
      VCR.use_cassette('auth/invalid_login') do
        auth = Resin::Modules::User.new
        expect {auth.login VALID_USER_EMAIL, INVALID_USER_PASSWORD}.to raise_error HTTParty::ResponseError
      end
    end
  end
end
