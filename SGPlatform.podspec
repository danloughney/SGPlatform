#
#  Be sure to run `pod spec lint SGPlatform.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
Pod::Spec.new do |s|
  s.name         = "SGPlatform"
  s.version      = "0.0.3"
  s.summary      = "Physical characteristics of iPhones and iPads."
  s.description  = <<-DESC
        While unusual, some apps need to know the physical size of the device upon which they are running. SGPlatform provides an object describing the physical characteristics of the local device.
        DESC
  s.homepage     = "http://spooky.group/pods/SGPlatform"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniel Loughney" => "dan@spooky.group" }
  s.social_media_url   = "http://twitter.com/dcloughney"
  s.platform                    = :ios
  s.ios.deployment_target       = "8.0"
  s.source = { :git => "https://github.com/danloughney/SGPlatform.git", :tag => "0.0.3" }
  s.source_files  = "Classes", "SGPlatform/*.{h,m}"
  s.public_header_files = "SGPlatform/*.h"
  s.requires_arc = true

end
