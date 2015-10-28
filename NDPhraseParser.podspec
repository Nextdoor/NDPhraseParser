#
# Be sure to run `pod lib lint NDPhraseParser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "NDPhraseParser"
  s.version          = "0.1.0"
  s.summary          = "A library that allows for formatting strings with context, like Python."
  s.description      = <<-DESC
                       A library that allows for formatting strings with context, like Python.
                       We wrote this library to allow us to pass strings with missing context
                       to our mobile applications. This library is _almost_ a direct port
                       of Square's awesome Android library Phrase: https://github.com/square/phrase
                       which we use in production at Nextdoor.
                     DESC

  s.homepage         = "https://github.com/Nextdoor/NDPhraseParser"
  s.license          = 'Apache 2.0'
  s.author           = { "Sean McQueen" => "mcqueen@nextdoor.com" }
  s.source           = { :git => "https://github.com/Nextdoor/NDPhraseParser.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/NextdoorEng'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'NDPhraseParser' => ['Pod/Assets/*.png']
  }

end
