#!/usr/bin/env python3
"""Generate BloomJournal.xcodeproj/project.pbxproj"""

import os
import uuid

def xcode_uuid():
    return uuid.uuid4().hex[:24].upper()

# UUIDs
IDs = {
    # File references
    'App_swift':            xcode_uuid(),
    'Vision_swift':         xcode_uuid(),
    'VisionStore_swift':    xcode_uuid(),
    'Theme_swift':          xcode_uuid(),
    'HomeView_swift':       xcode_uuid(),
    'JournalingView_swift': xcode_uuid(),
    'ReleaseView_swift':    xcode_uuid(),
    'VisionDetailView_swift': xcode_uuid(),
    'Assets_xcassets':      xcode_uuid(),
    'Preview_xcassets':     xcode_uuid(),

    # Build files
    'BF_App':               xcode_uuid(),
    'BF_Vision':            xcode_uuid(),
    'BF_VisionStore':       xcode_uuid(),
    'BF_Theme':             xcode_uuid(),
    'BF_HomeView':          xcode_uuid(),
    'BF_JournalingView':    xcode_uuid(),
    'BF_ReleaseView':       xcode_uuid(),
    'BF_VisionDetailView':  xcode_uuid(),
    'BF_Assets':            xcode_uuid(),
    'BF_Preview':           xcode_uuid(),

    # Groups
    'MainGroup':            xcode_uuid(),
    'SourcesGroup':         xcode_uuid(),
    'ModelsGroup':          xcode_uuid(),
    'ViewsGroup':           xcode_uuid(),
    'PreviewGroup':         xcode_uuid(),
    'ProductsGroup':        xcode_uuid(),

    # Target / Project
    'AppTarget':            xcode_uuid(),
    'AppProduct':           xcode_uuid(),
    'SourcesBuildPhase':    xcode_uuid(),
    'ResourcesBuildPhase':  xcode_uuid(),
    'FrameworksBuildPhase': xcode_uuid(),
    'DebugConfig':          xcode_uuid(),
    'ReleaseConfig':        xcode_uuid(),
    'TargetDebugConfig':    xcode_uuid(),
    'TargetReleaseConfig':  xcode_uuid(),
    'ProjectConfigList':    xcode_uuid(),
    'TargetConfigList':     xcode_uuid(),
    'Project':              xcode_uuid(),
}

pbxproj = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
		{IDs['BF_App']} /* BloomJournalApp.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {IDs['App_swift']} /* BloomJournalApp.swift */; }};
		{IDs['BF_Vision']} /* Vision.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {IDs['Vision_swift']} /* Vision.swift */; }};
		{IDs['BF_VisionStore']} /* VisionStore.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {IDs['VisionStore_swift']} /* VisionStore.swift */; }};
		{IDs['BF_Theme']} /* Theme.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {IDs['Theme_swift']} /* Theme.swift */; }};
		{IDs['BF_HomeView']} /* HomeView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {IDs['HomeView_swift']} /* HomeView.swift */; }};
		{IDs['BF_JournalingView']} /* JournalingView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {IDs['JournalingView_swift']} /* JournalingView.swift */; }};
		{IDs['BF_ReleaseView']} /* ReleaseView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {IDs['ReleaseView_swift']} /* ReleaseView.swift */; }};
		{IDs['BF_VisionDetailView']} /* VisionDetailView.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {IDs['VisionDetailView_swift']} /* VisionDetailView.swift */; }};
		{IDs['BF_Assets']} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {IDs['Assets_xcassets']} /* Assets.xcassets */; }};
		{IDs['BF_Preview']} /* Preview Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {IDs['Preview_xcassets']} /* Preview Assets.xcassets */; }};
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		{IDs['AppProduct']} /* BloomJournal.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = BloomJournal.app; sourceTree = BUILT_PRODUCTS_DIR; }};
		{IDs['App_swift']} /* BloomJournalApp.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BloomJournalApp.swift; sourceTree = "<group>"; }};
		{IDs['Vision_swift']} /* Vision.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Vision.swift; sourceTree = "<group>"; }};
		{IDs['VisionStore_swift']} /* VisionStore.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = VisionStore.swift; sourceTree = "<group>"; }};
		{IDs['Theme_swift']} /* Theme.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Theme.swift; sourceTree = "<group>"; }};
		{IDs['HomeView_swift']} /* HomeView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HomeView.swift; sourceTree = "<group>"; }};
		{IDs['JournalingView_swift']} /* JournalingView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = JournalingView.swift; sourceTree = "<group>"; }};
		{IDs['ReleaseView_swift']} /* ReleaseView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ReleaseView.swift; sourceTree = "<group>"; }};
		{IDs['VisionDetailView_swift']} /* VisionDetailView.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = VisionDetailView.swift; sourceTree = "<group>"; }};
		{IDs['Assets_xcassets']} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};
		{IDs['Preview_xcassets']} /* Preview Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "Preview Assets.xcassets"; sourceTree = "<group>"; }};
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{IDs['FrameworksBuildPhase']} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		{IDs['MainGroup']} = {{
			isa = PBXGroup;
			children = (
				{IDs['SourcesGroup']} /* BloomJournal */,
				{IDs['ProductsGroup']} /* Products */,
			);
			sourceTree = "<group>";
		}};
		{IDs['ProductsGroup']} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{IDs['AppProduct']} /* BloomJournal.app */,
			);
			name = Products;
			sourceTree = "<group>";
		}};
		{IDs['SourcesGroup']} /* BloomJournal */ = {{
			isa = PBXGroup;
			children = (
				{IDs['App_swift']} /* BloomJournalApp.swift */,
				{IDs['Theme_swift']} /* Theme.swift */,
				{IDs['ModelsGroup']} /* Models */,
				{IDs['ViewsGroup']} /* Views */,
				{IDs['Assets_xcassets']} /* Assets.xcassets */,
				{IDs['PreviewGroup']} /* Preview Content */,
			);
			path = BloomJournal;
			sourceTree = "<group>";
		}};
		{IDs['ModelsGroup']} /* Models */ = {{
			isa = PBXGroup;
			children = (
				{IDs['Vision_swift']} /* Vision.swift */,
				{IDs['VisionStore_swift']} /* VisionStore.swift */,
			);
			path = Models;
			sourceTree = "<group>";
		}};
		{IDs['ViewsGroup']} /* Views */ = {{
			isa = PBXGroup;
			children = (
				{IDs['HomeView_swift']} /* HomeView.swift */,
				{IDs['JournalingView_swift']} /* JournalingView.swift */,
				{IDs['ReleaseView_swift']} /* ReleaseView.swift */,
				{IDs['VisionDetailView_swift']} /* VisionDetailView.swift */,
			);
			path = Views;
			sourceTree = "<group>";
		}};
		{IDs['PreviewGroup']} /* Preview Content */ = {{
			isa = PBXGroup;
			children = (
				{IDs['Preview_xcassets']} /* Preview Assets.xcassets */,
			);
			path = "Preview Content";
			sourceTree = "<group>";
		}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{IDs['AppTarget']} /* BloomJournal */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {IDs['TargetConfigList']} /* Build configuration list for PBXNativeTarget "BloomJournal" */;
			buildPhases = (
				{IDs['SourcesBuildPhase']} /* Sources */,
				{IDs['FrameworksBuildPhase']} /* Frameworks */,
				{IDs['ResourcesBuildPhase']} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = BloomJournal;
			productName = BloomJournal;
			productReference = {IDs['AppProduct']} /* BloomJournal.app */;
			productType = "com.apple.product-type.application";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{IDs['Project']} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1420;
				LastUpgradeCheck = 1420;
				TargetAttributes = {{
					{IDs['AppTarget']} = {{
						CreatedOnToolsVersion = 14.2;
					}};
				}};
			}};
			buildConfigurationList = {IDs['ProjectConfigList']} /* Build configuration list for PBXProject "BloomJournal" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = ja;
			hasScannedForEncodings = 0;
			knownRegions = (
				ja,
				Base,
			);
			mainGroup = {IDs['MainGroup']};
			productRefGroup = {IDs['ProductsGroup']} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{IDs['AppTarget']} /* BloomJournal */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{IDs['ResourcesBuildPhase']} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{IDs['BF_Preview']} /* Preview Assets.xcassets in Resources */,
				{IDs['BF_Assets']} /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{IDs['SourcesBuildPhase']} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{IDs['BF_App']} /* BloomJournalApp.swift in Sources */,
				{IDs['BF_Vision']} /* Vision.swift in Sources */,
				{IDs['BF_VisionStore']} /* VisionStore.swift in Sources */,
				{IDs['BF_Theme']} /* Theme.swift in Sources */,
				{IDs['BF_HomeView']} /* HomeView.swift in Sources */,
				{IDs['BF_JournalingView']} /* JournalingView.swift in Sources */,
				{IDs['BF_ReleaseView']} /* ReleaseView.swift in Sources */,
				{IDs['BF_VisionDetailView']} /* VisionDetailView.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		{IDs['DebugConfig']} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			}};
			name = Debug;
		}};
		{IDs['ReleaseConfig']} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 16.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				VALIDATE_PRODUCT = YES;
			}};
			name = Release;
		}};
		{IDs['TargetDebugConfig']} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\\"BloomJournal/Preview Content\\"";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = UIInterfaceOrientationPortrait;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.bloomjournal.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 1;
			}};
			name = Debug;
		}};
		{IDs['TargetReleaseConfig']} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\\"BloomJournal/Preview Content\\"";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = UIInterfaceOrientationPortrait;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.bloomjournal.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 1;
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{IDs['ProjectConfigList']} /* Build configuration list for PBXProject "BloomJournal" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{IDs['DebugConfig']} /* Debug */,
				{IDs['ReleaseConfig']} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{IDs['TargetConfigList']} /* Build configuration list for PBXNativeTarget "BloomJournal" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{IDs['TargetDebugConfig']} /* Debug */,
				{IDs['TargetReleaseConfig']} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */
	}};
	rootObject = {IDs['Project']} /* Project object */;
}}
"""

# Write project files
project_dir = "BloomJournal.xcodeproj"
os.makedirs(project_dir, exist_ok=True)

with open(os.path.join(project_dir, "project.pbxproj"), "w") as f:
    f.write(pbxproj)

# Assets.xcassets
assets_dir = "BloomJournal/Assets.xcassets"
os.makedirs(assets_dir, exist_ok=True)
with open(os.path.join(assets_dir, "Contents.json"), "w") as f:
    f.write('{\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n')

appicon_dir = os.path.join(assets_dir, "AppIcon.appiconset")
os.makedirs(appicon_dir, exist_ok=True)
with open(os.path.join(appicon_dir, "Contents.json"), "w") as f:
    f.write('{\n  "images" : [],\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n')

accent_dir = os.path.join(assets_dir, "AccentColor.colorset")
os.makedirs(accent_dir, exist_ok=True)
with open(os.path.join(accent_dir, "Contents.json"), "w") as f:
    f.write('{\n  "colors" : [\n    {\n      "idiom" : "universal"\n    }\n  ],\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n')

# Preview Assets
preview_dir = "BloomJournal/Preview Content/Preview Assets.xcassets"
os.makedirs(preview_dir, exist_ok=True)
with open(os.path.join(preview_dir, "Contents.json"), "w") as f:
    f.write('{\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n')

print("Done! BloomJournal.xcodeproj generated successfully.")
