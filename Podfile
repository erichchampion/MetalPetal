
abstract_target 'MetalPetalExamples' do
  use_frameworks!

  pod 'MetalPetal/Swift', :path => 'Frameworks/MetalPetal'

  target 'MetalPetalExamples (iOS)' do
    platform :ios, '18.0'
  end
  
  target 'MetalPetalExamples (macOS)' do
    platform :macos, '11.0'

    pod 'MetalPetal/AppleSilicon', :path => 'Frameworks/MetalPetal'
  end
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if target.name == 'MetalPetal-AppleSilicon-Core-Swift'
        target.build_configurations.each do |config|
          # Exclude from iOS builds to prevent framework linking conflicts
          config.build_settings['EXCLUDED_ARCHS[sdk=iphoneos*]'] = '$(ARCHS_STANDARD)'
          config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = '$(ARCHS_STANDARD)'
          config.build_settings['SUPPORTED_PLATFORMS'] = 'macosx'
        end
      end
      
      # Update iOS deployment target to 18.0 for all iOS targets
      target.build_configurations.each do |config|
        if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 18.0
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.0'
        end
      end
    end
    
    # Add SWIFT_INCLUDE_PATHS to the app target's Pods xcconfig files for iOS
    installer.pods_project.targets.each do |target|
      if target.name == 'Pods-MetalPetalExamples-MetalPetalExamples (iOS)'
        ['Debug', 'Release'].each do |config_name|
          xcconfig_path = File.join(installer.sandbox.root.to_s, 'Target Support Files', target.name, "#{target.name}.#{config_name.downcase}.xcconfig")
          if File.exist?(xcconfig_path)
            xcconfig = File.read(xcconfig_path)
            unless xcconfig.include?('SWIFT_INCLUDE_PATHS')
              xcconfig += "\nSWIFT_INCLUDE_PATHS = $(inherited) \"${PODS_CONFIGURATION_BUILD_DIR}/MetalPetal-Core-Swift\"\n"
              File.write(xcconfig_path, xcconfig)
            end
            # Add framework search path to Swift compiler flags
            xcconfig = File.read(xcconfig_path)
            if xcconfig.include?('OTHER_SWIFT_FLAGS') && !xcconfig.include?('-F "${PODS_CONFIGURATION_BUILD_DIR}/MetalPetal-Core-Swift"')
              xcconfig = xcconfig.gsub(/OTHER_SWIFT_FLAGS = (.+)/, "OTHER_SWIFT_FLAGS = \\1 -F \"${PODS_CONFIGURATION_BUILD_DIR}/MetalPetal-Core-Swift\"")
              File.write(xcconfig_path, xcconfig)
            end
          end
        end
      end
    end
  end
end


