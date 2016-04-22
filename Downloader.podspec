#
# Be sure to run `pod lib lint Downloader.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Downloader"
  s.version          = "0.0.6"
  s.summary          = "这是我们的第一个支持本地私有库<Downloader>,请大家多多关照,多给建议和支持"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                        A description of the Pod more detailed than the summary. 就是对当前lib的详细功能的详细描述吧。我猜的
                       DESC

  s.homepage         = "https://chengqihan@git.vmovier.cc/scm/~chengqihan/downloaderlib"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "chengqihan" => "chengqihan@vmovier.com" }
  s.source           = { :git => "https://chengqihan@git.vmovier.cc/scm/~chengqihan/downloaderlib.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Downloader' => ['Pod/Assets/*.png']
  }
  s.prefix_header_file = 'Example/Pods/Target Support Files/Downloader/Downloader-prefix.pch'
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'FMDB'
    s.dependency 'AFNetworking', '~> 3.0'
  # s.dependency 'StateMachine', '~> 0.3.0'
end
