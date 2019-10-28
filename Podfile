# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Jobfizzer' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
    pod 'GoogleMaps'
    pod 'GooglePlaces'
    pod 'GooglePlacePicker'
    pod 'Cosmos', '~> 12.0'
    pod 'IQKeyboardManagerSwift'
    pod 'Alamofire', '~> 4.5'
    pod 'SwiftyJSON'
    pod 'SwiftSpinner'
    pod 'Nuke', '~> 5.0'
    pod 'Firebase/Core'
    pod 'Firebase/Messaging'
    pod 'Socket.IO-Client-Swift', '~> 13.0.0'
#    pod 'FacebookCore'
#    pod 'FacebookLogin'

pod 'FacebookCore', :git => 'https://github.com/facebook/facebook-sdk-swift', :branch => 'master'
pod 'FacebookLogin', :git => 'https://github.com/facebook/facebook-sdk-swift', :branch => 'master'
pod 'FacebookShare', :git => 'https://github.com/facebook/facebook-sdk-swift', :branch => 'master'


#    pod 'KRProgressHUD'

    pod 'Stripe'
    pod 'Firebase/Auth'
    pod 'GoogleSignIn'
    pod 'NextGrowingTextView'
    pod 'SDWebImage'
    pod 'SimpleImageViewer', '~> 1.1.1'
    pod 'PDFReader'

    pod 'Localize-Swift'
    pod 'RZTransitions'

    pod 'CenteredCollectionView'
    pod 'Floaty'
    pod 'AWSCore'
    pod 'AWSS3'
    pod 'Fabric'
    pod 'Crashlytics'

    
    post_install do |installer|
        installer.pods_project.build_configurations.each do |config|
            config.build_settings.delete('CODE_SIGNING_ALLOWED')
            config.build_settings.delete('CODE_SIGNING_REQUIRED')
        end
        
        installer.pods_project.targets.each do |target|
            if ['Floaty'].include? target.name
                target.build_configurations.each do |config|
                    config.build_settings['SWIFT_VERSION'] = ‘4.2’
                end
            end
            
        end
        
    end


  # Pods for UberdooX

end
