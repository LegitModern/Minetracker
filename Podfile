platform :ios, '8.0'
use_frameworks!

target 'Minetracker' do

pod 'SwiftyJSON', :git => 'https://github.com/IBM-Swift/SwiftyJSON.git'
pod 'MBProgressHUD', '~> 1.0'
pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'
pod 'Firebase/Analytics', '~> 3.6'
pod 'Firebase/Crash', '~> 3.6'
pod 'Firebase/Messaging', '~> 3.6'
pod 'Socket.IO-Client-Swift', '~> 8.0'
pod 'NYAlertViewController', '~> 1.3'

end

target 'MinetrackerTests' do

pod 'SwiftyJSON', :git => 'https://github.com/IBM-Swift/SwiftyJSON.git'
pod 'MBProgressHUD', '~> 1.0'
pod 'Spring', :git => 'https://github.com/MengTo/Spring.git'
pod 'Firebase/Analytics', '~> 3.6'
pod 'Firebase/Crash', '~> 3.6'
pod 'Firebase/Messaging', '~> 3.6'
pod 'Socket.IO-Client-Swift', '~> 8.0' 
pod 'NYAlertViewController', '~> 1.3'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
