require 'shellwords'
MIN_IOS_VERSION = '12.0'

# Uncomment the next line to define a global platform for your project
platform :ios, MIN_IOS_VERSION
inhibit_all_warnings!

target 'ok55leg' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  # Pods for OAECLegGuide
  pod "PushwooshXCFramework"

  pod 'Realm', '~>10'
  source 'https://github.com/CocoaPods/Specs.git'
  platform :ios, MIN_IOS_VERSION
  pod 'AFNetworking'

  pod 'SSZipArchive'

end

post_install do |installer|
  installer.pods_project.root_object.attributes['LastUpgradeCheck'] = '2620'

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = MIN_IOS_VERSION
      config.build_settings['CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER'] = 'NO'
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'

      ldflags = config.build_settings['OTHER_LDFLAGS']
      next if ldflags.nil?

      tokens = if ldflags.is_a?(Array)
                 ldflags.dup
               else
                 Shellwords.shellsplit(ldflags.to_s)
               end

      filtered_tokens = tokens.each_with_object([]) do |token, acc|
        normalized = token.delete('"')
        next if normalized == '-lc++' || normalized == '-lstdc++'
        acc << token
      end

      config.build_settings['OTHER_LDFLAGS'] =
        ldflags.is_a?(Array) ? filtered_tokens : filtered_tokens.shelljoin
    end
    target.shell_script_build_phases.each do |phase|
      if phase.name == 'Create Symlinks to Header Folders'
        phase.always_out_of_date = '1'
      end
    end
  end

  installer.aggregate_targets.each do |aggregate_target|
    user_project = aggregate_target.user_project
    user_project.root_object.attributes['LastUpgradeCheck'] = '2620'

    user_project.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = MIN_IOS_VERSION
    end

    user_project.native_targets.each do |native_target|
      native_target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = MIN_IOS_VERSION
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      end
    end
    user_project.save
  end

  target_support_files = installer.sandbox.root + 'Target Support Files'
  Dir.glob("#{target_support_files}/**/*.xcconfig").each do |xcconfig_path|
    content = File.read(xcconfig_path)
    updated = content
      .gsub(/\s-l"?c\+\+"?/, '')
      .gsub(/\s-l"?stdc\+\+"?/, '')

    next if updated == content

    File.write(xcconfig_path, updated)
  end

  installer.pods_project.save
end
