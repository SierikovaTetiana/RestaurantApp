platform :ios, '12.0'

target 'DeGusto' do
  
    use_frameworks!

  # Pods for DeGusto

  pod 'DatePickerDialog'

  pod 'PhoneNumberKit', '~> 3.3'
  pod 'NotificationBannerSwift', '~> 3.0.0'
  pod 'FBSDKLoginKit'
  pod 'FBSDKCoreKit'
  pod 'ReachabilitySwift'
  pod 'FaveButton'
  pod 'PKYStepper', '0.0.1'
  pod 'SDStateTableView'
  pod 'IQKeyboardManagerSwift'
  pod 'GooglePlaces'

    
    pod 'Firebase/Auth'
    pod 'Firebase/Firestore'
    pod 'Firebase/Storage'
    pod 'Firebase/Database'

    post_install do |installer|
      installer.pods_project.build_configurations.each do |config|
        config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      end
    end

  end
