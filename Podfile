platform :ios, '11.0'

target 'WebRTCMobileDemo' do
  use_frameworks!
  
    pod 'MessageKit'
    pod 'GoogleWebRTC'
    pod 'Socket.IO-Client-Swift'
    pod 'SVProgressHUD'
    pod 'IQKeyboardManagerSwift'
    pod 'SnapKit'
    pod 'SkyFloatingLabelTextField', :git => 'https://github.com/Skyscanner/SkyFloatingLabelTextField'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == "GoogleWebRTC"
            target.build_configurations.each do |config|
                config.build_settings['ENABLE_BITCODE'] = 'NO'
            end
        end
    end
end
