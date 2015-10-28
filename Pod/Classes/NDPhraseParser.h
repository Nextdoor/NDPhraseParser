//
//  NDPhraseParser.h
//
//  Copyright 2015 Nextdoor.com, Inc
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <Foundation/Foundation.h>


/**
 *  Error codes for this parser.
 */
typedef NS_ENUM (NSInteger, NDPhraseParserErrorCode){
    /**
     *  Error which means there wasn't enough context given to the parser to fully
     *  replace keys in the pattern.
     */
    NDPhraseParserErrorCodeMissingContext = 1,
    /**
     *  Error which means the given pattern was malformed; we hit a non-legal character.
     */
    NDPhraseParserErrorCodeUnexpectedCharacter = 2,
};

/**
 *  A class that allows for parsing, tokenizing and formatting
 *  a specific formatting of strings, like Python.
 */
@interface NDPhraseParser : NSObject

/**
 *  Format a string with context.
 *
 *  Example:
 *
 *     NSError *error;
 *     NSString *pattern = @"{user_name} lives in {city_name}";
 *     NSDictionary *context = @{@"user_name": @"Sean McQueen", @"city_name": "San Francisco"};
 *     NSString *formattedString = [NDPhraseParser formatStringWithPattern:pattern context:context errorPtr:&error];
 *     if (!*error) {
 *         // use formattedString
 *     }
 *
 *  @param pattern The pattern to format (i.e. @"this is a string with {key_number_one}")
 *  @param context A dictionary of context to format with, strings mapped to strings.
 *                 (i.e. @{"key_number_one": "a string value"})
 *  @param error   A pointer to a pointer to an error. Gets set if something goes wrong.
 *
 *  @return A formatted string.
 */
+ (NSString *)formatStringWithPattern:(NSString *)pattern
                              context:(NSDictionary *)context
                             errorPtr:(NSError **)error;

@end
