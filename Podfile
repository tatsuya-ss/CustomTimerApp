# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'CustomTimerApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Firebase
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'   # Optionally, include the Swift extensions if you're using Swift.
  pod 'Firebase/Storage'
  
  # PKHUD
  pod 'PKHUD'
  
  # Pods for CustomTimerApp
  
  target 'CustomTimerAppTests' do
    inherit! :search_paths
    # Pods for testing
  end
  
  target 'CustomTimerAppUITests' do
    # Pods for testing
  end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end  

end
