use_frameworks!
platform :ios, '9.0'
inhibit_all_warnings!

target 'DynamicTypeExampleTests' do
  pod 'FBSnapshotTestCase',
    :git => 'git@github.com:willowtreeapps/ios-snapshot-test-case.git',
    :branch => 'feature/swift-3'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
