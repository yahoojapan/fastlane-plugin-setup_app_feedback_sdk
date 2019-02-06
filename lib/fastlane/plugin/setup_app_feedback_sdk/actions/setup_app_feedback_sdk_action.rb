require 'fastlane/action'
require_relative '../helper/setup_app_feedback_sdk_helper'

module Fastlane
  module Actions
    class SetupAppFeedbackSdkAction < Action
      def self.run(params)
        require 'xcodeproj'
        require 'shellwords'
        require 'pathname'

        plist = plist_path(params)

        SetInfoPlistValueAction.run(key: 'AppFeedback_SlackApiToken', value: params[:slack_api_token], path: plist)
        SetInfoPlistValueAction.run(key: 'AppFeedback_SlackChannel', value: params[:slack_channel], path: plist)

        if params[:slack_api_url]
          SetInfoPlistValueAction.run(key: 'AppFeedback_SlackApiUrl', value: params[:slack_api_url], path: plist)
        end

        if other_action.git_branch
          SetInfoPlistValueAction.run(key: 'AppFeedback_Branch', value: other_action.git_branch, path: plist)
        end
      end

      def self.plist_path(params)
        require 'xcodeproj'

        project_path = params[:project]

        shared_data_dir = Xcodeproj::XCScheme.shared_data_dir(project_path)
        scheme_path = File.join(shared_data_dir, params[:scheme] + '.xcscheme')
        UI.verbose("scheme_path = #{scheme_path}")

        scheme = Xcodeproj::XCScheme.new(scheme_path)

        build_action = scheme.build_action
        archive_entries = build_action.entries.select(&:build_for_archiving?)
        target_names = archive_entries.flat_map { |entry| entry.buildable_references.map(&:target_name) }
        UI.verbose("target_names = #{target_names}")
        project = Xcodeproj::Project.open(project_path)

        # select iOS Target
        target = project.native_targets.detect do |t|
          target_names.include?(t.name) && t.platform_name == :ios && t.product_type == 'com.apple.product-type.application'
        end
        UI.user_error!("Couldn't find iOS target for scheme '#{params[:scheme]}'") unless target

        UI.verbose("target = #{target}")

        config = target.build_configurations.detect { |c| c.name == params[:configuration] }
        UI.user_error!("Couldn't find configuration named '#{params[:configuration]}'") unless config

        plist = config.build_settings['INFOPLIST_FILE']
        UI.user_error!("Couldn't find INFOPLIST_FILE") unless plist

        # Use showBuildSettings when plist path contains variable.
        # ( showBuildSettings is slow )
        if plist.include?('$')
          settings = build_settings(project: params[:project], configuration: params[:configuration], target: target.name)
          plist = settings['INFOPLIST_FILE']
          UI.user_error!("Couldn't find INFOPLIST_FILE in showBuildSettings") unless plist
        end

        plist = File.join(File.dirname(params[:project]), plist) if Pathname.new(plist).relative?
        UI.user_error!("Couldn't find plist file at path '#{plist}'") unless File.exist?(plist)

        plist = File.expand_path(plist)

        UI.verbose("plist path = #{plist}")
        plist
      end

      def self.build_settings(params)
        command = build_settings_command(params)
        output = FastlaneCore::Project.run_command(command,
                                                   timeout: FastlaneCore::Project.xcode_build_settings_timeout,
                                                   retries: FastlaneCore::Project.xcode_build_settings_retries,
                                                   print: FastlaneCore::Globals.verbose?)
        parse_build_settings(output)
      end

      def self.build_settings_command(params)
        params = {
          '-project' => params[:project],
          '-target' => params[:target],
          '-configuration' => params[:configuration]
        }
        params_str = params.map { |k, v| "#{k} #{v.shellescape}" }.join(' ')
        "xcodebuild clean -showBuildSettings #{params_str}"
      end

      def self.parse_build_settings(output)
        settings = {}
        output.lines.each do |line|
          m = line.match(/^\s*(\S+)\s*=\s*(.+)$/)
          settings[m[1]] = m[2] if m
        end
        settings
      end

      def self.description
        "Setup the Info.plist for App Feedback SDK"
      end

      def self.authors
        ["Yahoo! Japan"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        "This fastlane plugin helps with App Feedback SDK integration for CI services"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :slack_api_token,
                                       env_name: "SLACK_API_TOKEN",
                                       description: "Slack API token",
                                       sensitive: true,
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :slack_channel,
                                       env_name: "APP_FEEDBACK_SDK_SLACK_CHANNEL",
                                       description: "Slack channel",
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :slack_api_url,
                                       env_name: "APP_FEEDBACK_SLACK_API_URL",
                                       description: "Slack API URL",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :project,
                                       env_name: 'APP_FEEDBACK_SDK_PROJECT',
                                       description: 'Path to your Xcode project',
                                       type: String,
                                       optional: false,
                                       verify_block: proc do |value|
                                         UI.user_error!('Please pass the path to the project, not the workspace') if value.end_with?('.xcworkspace')
                                         UI.user_error!('Could not find Xcode project') unless File.exist?(value)
                                       end),
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: 'APP_FEEDBACK_SDK_SCHEME',
                                       description: 'Scheme of info plist',
                                       type: String,
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :configuration,
                                       env_name: 'APP_FEEDBACK_SDK_CONFIGURATION',
                                       description: 'Configuration of info plist',
                                       type: String,
                                       optional: false)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        [:ios].include?(platform)
      end
    end
  end
end
