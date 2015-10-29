NDPhraseParser - iOS string formatting
======================================

[![license](http://img.shields.io/badge/license-apache_2.0-red.svg?style=flat)](https://github.com/Nextdoor/NDPhraseParser/blob/master/README.md)

This is an Objective-C port of (some of) [Square's Android Phrase library](https://github.com/square/phrase). It allows you to format a string with named keys and context, like Python's format function:

```python
'{user_name} lives in {city_name}'.format(user_name='Sean McQueen', city_name='San Francisco')
```

Example:
--------

```obj-c
NSError *error;
NSString *pattern = @"{user_name} lives in {city_name}";
NSDictionary *context = @{@"user_name": @"Sean McQueen", @"city_name": "San Francisco"};
NSString *formattedString = [NDPhraseParser formatStringWithPattern:pattern context:context errorPtr:&error];
if (!error) {
  // use formattedString
}
```

Download
--------

```bash
pod install NDPhraseParser
```

License
-------

    Copyright 2013 Nextdoor.com, Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
