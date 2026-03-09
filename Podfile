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
        config.build_settings['GCC_GENERATE_DEBUGGING_SYMBOLS'] = 'YES'
        config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
      end

      next unless native_target.name == 'ok55leg'

      phase_name = 'Generate Pushwoosh dSYM for Archive'
      phase = native_target.shell_script_build_phases.find { |p| p.name == phase_name }
      phase ||= native_target.new_shell_script_build_phase(phase_name)
      phase.shell_path = '/bin/sh'
      phase.input_paths = [
        '${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/PushwooshFramework.framework/PushwooshFramework',
        '${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/PushwooshBridge.framework/PushwooshBridge',
        '${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/PushwooshCore.framework/PushwooshCore'
      ]
      phase.output_paths = [
        '${DWARF_DSYM_FOLDER_PATH}/PushwooshFramework.framework.dSYM/Contents/Resources/DWARF/PushwooshFramework',
        '${DWARF_DSYM_FOLDER_PATH}/PushwooshBridge.framework.dSYM/Contents/Resources/DWARF/PushwooshBridge',
        '${DWARF_DSYM_FOLDER_PATH}/PushwooshCore.framework.dSYM/Contents/Resources/DWARF/PushwooshCore'
      ]
      phase.shell_script = <<~'SCRIPT'
        set -euo pipefail

        if [ "${ACTION:-}" != "install" ]; then
          exit 0
        fi

        DSYM_OUTPUT_DIR="${DWARF_DSYM_FOLDER_PATH}"
        mkdir -p "$DSYM_OUTPUT_DIR"

        for framework_name in PushwooshFramework PushwooshBridge PushwooshCore; do
          FRAMEWORK_BINARY="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/${framework_name}.framework/${framework_name}"
          DSYM_OUTPUT_PATH="${DSYM_OUTPUT_DIR}/${framework_name}.framework.dSYM"

          if [ ! -f "$FRAMEWORK_BINARY" ]; then
            echo "[OAEC][dSYM] ${framework_name} binary not found at $FRAMEWORK_BINARY"
            continue
          fi

          DSYM_STDERR_LOG="$(mktemp)"
          if ! /usr/bin/dsymutil "$FRAMEWORK_BINARY" -o "$DSYM_OUTPUT_PATH" 2>"$DSYM_STDERR_LOG"; then
            cat "$DSYM_STDERR_LOG" >&2
            rm -f "$DSYM_STDERR_LOG"
            exit 1
          fi
          # Pushwoosh ships precompiled without full debug symbols; suppress that noisy warning.
          /usr/bin/grep -v "warning: no debug symbols in executable" "$DSYM_STDERR_LOG" >&2 || true
          rm -f "$DSYM_STDERR_LOG"
          echo "[OAEC][dSYM] Generated ${framework_name} dSYM at $DSYM_OUTPUT_PATH"
        done
      SCRIPT
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

  sszip_header_rewrites = {
    installer.sandbox.root + 'SSZipArchive/SSZipArchive/SSZipArchive.h' => [
      ['#import <SSZipArchive/SSZipCommon.h>', '#import "SSZipCommon.h"']
    ],
    installer.sandbox.root + 'Target Support Files/SSZipArchive/SSZipArchive-umbrella.h' => [
      ['#import <SSZipArchive/SSZipArchive.h>', '#import "SSZipArchive.h"'],
      ['#import <SSZipArchive/SSZipCommon.h>', '#import "SSZipCommon.h"']
    ]
  }

  sszip_header_rewrites.each do |header_path, replacements|
    next unless File.exist?(header_path)

    begin
      File.chmod(0644, header_path)
    rescue SystemCallError
      # Best effort; continue so installs do not fail if permissions are already correct.
    end

    content = File.read(header_path)
    updated = replacements.reduce(content) do |memo, (old_string, new_string)|
      memo.gsub(old_string, new_string)
    end

    next if updated == content

    File.write(header_path, updated)
  end

  installer.pods_project.save
end
