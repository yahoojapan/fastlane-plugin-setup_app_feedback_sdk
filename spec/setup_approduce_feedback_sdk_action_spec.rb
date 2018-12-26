describe Fastlane::Actions::SetupAppFeedbackSdkAction do
  describe '#run' do
    def plist
      File.read(__dir__ + '/../iOSTestApp/iOSTestApp/Info.plist')
    end

    def reset_plist
      system("git checkout iOSTestApp/iOSTestApp/Info.plist")
    end

    before do
      reset_plist
    end

    after do
      reset_plist
    end

    it 'Set slack settings to Info.plist' do
      ff = Fastlane::FastFile.new.parse(<<EOL)
lane :test do
  setup_app_feedback_sdk(
        project: __dir__ + '/../iOSTestApp/iOSTestApp.xcodeproj',
        scheme: 'iOSTestApp',
        configuration: 'Release',
        slack_api_token: 'dummy_token',
        slack_channel: 'dummy_channel'
  )
end
EOL

      ff.runner.execute(:test)

      expect(plist).to include('AppFeedback_SlackApiToken')
      expect(plist).to include('dummy_token')

      expect(plist).to include('AppFeedback_SlackChannel')
      expect(plist).to include('dummy_channel')
    end

    it 'Set branch name to Info.plist' do
      ff = Fastlane::FastFile.new.parse(<<EOL)
lane :test do
  setup_app_feedback_sdk(
        project: __dir__ + '/../iOSTestApp/iOSTestApp.xcodeproj',
        scheme: 'iOSTestApp',
        configuration: 'Release',
        slack_api_token: 'dummy_token',
        slack_channel: 'dummy_channel'
  )
end
EOL

      ENV['GIT_BRANCH'] = 'dummy_branch'

      ff.runner.execute(:test)

      ENV.delete('GIT_BRANCH')

      expect(plist).to include('AppFeedback_Branch')
      expect(plist).to include('dummy_branch')
    end
  end
end
