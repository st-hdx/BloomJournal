#!/usr/bin/env ruby
# Adds a permanent BloomJournalUITests (:ui_test_bundle) target + shared scheme
# to the committed project.pbxproj, wired to the BloomJournal app target.
#
# Run with the user-installed gem visible:
#   GEM_HOME=/Users/takayanagi/.gem/ruby/2.6.0 ruby scripts/add_uitest_target.rb
#
# Idempotent: if the target already exists it is removed and recreated so the
# build settings below are authoritative.

require 'xcodeproj'

ROOT          = File.expand_path('..', __dir__)
PROJECT_PATH  = File.join(ROOT, 'BloomJournal.xcodeproj')
APP_TARGET    = 'BloomJournal'
TEST_TARGET   = 'BloomJournalUITests'
TEST_GROUP    = 'BloomJournalUITests'
TEST_SOURCE   = 'ScreenshotTests.swift'
TEAM          = 'Y5RBKYD4FY'

project = Xcodeproj::Project.open(PROJECT_PATH)

app = project.targets.find { |t| t.name == APP_TARGET }
raise "App target #{APP_TARGET.inspect} not found" unless app

# --- Remove any prior test target / group so we recreate cleanly ------------
if (old = project.targets.find { |t| t.name == TEST_TARGET })
  puts "Removing existing target #{TEST_TARGET} to recreate"
  old.remove_from_project
end
if (old_group = project.main_group[TEST_GROUP])
  old_group.remove_from_project
end

# --- Create the UI test bundle target --------------------------------------
test = project.new_target(:ui_test_bundle, TEST_TARGET, :ios, '16.0')

# --- Attach the test source -------------------------------------------------
group = project.main_group.new_group(TEST_GROUP, TEST_GROUP)
file_ref = group.new_reference(TEST_SOURCE)
test.add_file_references([file_ref])

# --- Build settings (mirror the app target's platform/toolchain) -----------
test.build_configurations.each do |config|
  s = config.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.pandagiken.bloomjournal.app.uitests'
  s['PRODUCT_NAME']              = '$(TARGET_NAME)'
  s['DEVELOPMENT_TEAM']          = TEAM
  s['TEST_TARGET_NAME']          = APP_TARGET
  s['CODE_SIGNING_ALLOWED']      = 'NO'
  s['CODE_SIGN_STYLE']           = 'Automatic'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
  s['SWIFT_VERSION']             = '5.0'
  s['GENERATE_INFOPLIST_FILE']   = 'YES'
  s['TARGETED_DEVICE_FAMILY']    = '1,2'
  s['MARKETING_VERSION']         = '1.0'
  s['CURRENT_PROJECT_VERSION']   = '1'
  s['SWIFT_EMIT_LOC_STRINGS']    = 'NO'
  s['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
end

# --- Depend on the app target ----------------------------------------------
test.add_dependency(app)

project.save
puts "Saved project with target #{TEST_TARGET}"

# --- Shared scheme so `xcodebuild -scheme BloomJournal` can run the tests ---
scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.add_test_target(test)
scheme.set_launch_target(app)
scheme.save_as(PROJECT_PATH, APP_TARGET, true) # shared = true
puts "Wrote shared scheme #{APP_TARGET}.xcscheme"
