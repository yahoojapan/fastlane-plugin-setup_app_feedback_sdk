# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/setup_app_feedback_sdk/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-setup_app_feedback_sdk'
  spec.version       = Fastlane::SetupAppFeedbackSdk::VERSION
  spec.author        = 'Yahoo Japan Corporation'
  spec.email         = 'dummy@mail.yahoo.co.jp'

  spec.summary       = 'Setup the Info.plist for App Feedback SDK'
  spec.homepage      = "https://github.com/yahoojapan/fastlane-plugin-setup_app_feedback_sdk"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.105.2')
end