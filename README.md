NDPhraseParser - iOS string formatting
======================================

[![license](http://img.shields.io/badge/license-apache_2.0-red.svg?style=flat)](https://github.com/Nextdoor/NDPhraseParser/blob/master/LICENSE) | [![Build Status](https://travis-ci.org/Nextdoor/NDRefresh.svg?branch=master)](https://travis-ci.org/Nextdoor/NDPhraseParser) | [![CocoaPods](https://img.shields.io/cocoapods/v/NDPhraseParser.svg)](http://cocoadocs.org/docsets/NDPhraseParser/0.1.0/)

This is an Objective-C port of (some of) [Square's Android Phrase library](https://github.com/square/phrase). It allows you to format a string with named keys and context, like Python:

```python
'There are {num_neighborhoods} in {city_name}'.format(num_neighborhoods='200', city_name='San Francisco')
```

Example:
--------

```swift
let pattern : String = "{user_name} lives in {neighborhood_name}"
let context : [String:String] = ["user_name": "Sean McQueen", "neighborhood_name": "Lower Nob Hill"]
do {
    let formattedString : String = try NDPhraseParser.formatStringWithPattern(pattern, context: context)
    // use formattedString
} catch let error as NSError {
    // handle error
}
```

```obj-c
NSError *error;
NSString *pattern = @"View {num_replies} replies to your recent post!";
NSDictionary *context = @{@"num_replies": @"6"};
NSString *formattedString = [NDPhraseParser formatStringWithPattern:pattern context:context errorPtr:&error];
if (!error) {
  // use formattedString
}
```

Download
--------

```pod install NDPhraseParser```

License
-------

    Copyright 2015 Nextdoor.com, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
