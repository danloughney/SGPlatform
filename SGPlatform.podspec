#
#  Be sure to run `pod spec lint SGPlatform.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "SGPlatform"
  s.version      = "0.0.1"
  s.summary      = "Physical characteristics of iPhones and iPads."

  s.description  = <<-DESC
While unusual, some apps need to know the physical size of the device upon which they are running. SGPlatform provides an object describing the physical characteristics of the local device.
                   DESC

  s.homepage     = "http://spooky.group/pods/SGPlatform"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Daniel Loughney" => "dan@spooky.group" }
  s.social_media_url   = "http://twitter.com/dcloughney"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #
  s.platform     = :ios, "7.0"


  s.source = { :git => "https://github.com/danloughney/SGPlatform.git", :tag => "0.0.1" }

  s.source_files  = "Classes", "SGPlatform/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.public_header_files = "SGPlatform/*.h"


  s.requires_arc = true

end
