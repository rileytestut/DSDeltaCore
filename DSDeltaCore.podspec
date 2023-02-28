Pod::Spec.new do |spec|
  spec.name         = "DSDeltaCore"
  spec.version      = "0.1"
  spec.summary      = "Nintendo DS plug-in for Delta emulator."
  spec.description  = "iOS framework that wraps DeSmuME to allow playing Nintendo DS games with Delta emulator."
  spec.homepage     = "https://github.com/rileytestut/DSDeltaCore"
  spec.platform     = :ios, "14.0"
  spec.source       = { :git => "https://github.com/rileytestut/DSDeltaCore.git" }

  spec.author             = { "Riley Testut" => "riley@rileytestut.com" }
  spec.social_media_url   = "https://twitter.com/rileytestut"
  
  spec.source_files  = "DSDeltaCore/**/*.{swift}", "DSDeltaCore/Bridge/DSEmulatorBridge.mm", "DSDeltaCore/Types/DSTypes.{h,m}", "desmume/desmume/src/*.{h,hpp}", "desmume/desmume/src/libretro-common/include/*.{h,hpp}", "desmume/desmume/src/libretro-common/include/math/*.{h,hpp}", "desmume/desmume/src/metaspu/**/*.{h,hpp}", "libDeSmuME/*.{h,hpp}"
  spec.public_header_files = "DSDeltaCore/Types/DSTypes.h", "DSDeltaCore/Bridge/DSEmulatorBridge.h"
  spec.header_mappings_dir = ""
  spec.resource_bundles = {
    "DSDeltaCore" => ["DSDeltaCore/**/*.deltamapping", "DSDeltaCore/**/*.deltaskin"]
  }
  
  spec.dependency 'DeltaCore'
    
  spec.xcconfig = {
    "HEADER_SEARCH_PATHS" => '"${PODS_CONFIGURATION_BUILD_DIR}" "$(PODS_ROOT)/Headers/Private/DSDeltaCore/desmume/desmume/src/libretro-common/include"',
    "USER_HEADER_SEARCH_PATHS" => '"${PODS_CONFIGURATION_BUILD_DIR}/DeltaCore/Swift Compatibility Header"',
    "OTHER_CFLAGS" => "-DHOST_DARWIN -DDESMUME_COCOA -DHAVE_OPENGL -DHAVE_LIBZ -DANDROID -fexceptions -ftree-vectorize -DCOMPRESS_MT -DIOS -DOBJ_C -marm -fvisibility=hidden -DSTATIC_LIBRARY=1"
}
  
end
