RSpec.describe Resin::Settings do
  include FakeFS::SpecHelpers

  it 'should create a correct default configuration' do
    FakeFS.with_fresh do
      settings = nil
      expect {
        settings = Resin::Settings.instance
      }.not_to raise_error

      expect(settings).not_to be_nil

      expect(File.exist? CONFIG_FILE_PATH).to be_truthy

      all_options = settings.get

      expect(all_options).to eq(Resin::Settings::DEFAULT_SETTINGS)
    end
  end

  # Test for reading a cfg not matching the default entries

end
