require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class SetupAppFeedbackSdkHelper
      # class methods that you define here become available in your action
      # as `Helper::SetupAppFeedbackSdkHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the setup_app_feedback_sdk plugin helper!")
      end
    end
  end
end
