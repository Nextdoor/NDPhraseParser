
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

  # TODO(McQueen): bring this back when it is a public repo - or use OSS website when it exists
  # s.homepage         = "https://github.com/Nextdoor/NDPhraseParser"
  s.homepage         = 'http://nextdoor.com'
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
