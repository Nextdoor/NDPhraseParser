//
//  NDPhraseParserTest.m
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


@import XCTest;

#import <NDPhraseParser.h>

@interface Tests : XCTestCase

@end

@implementation Tests


- (void)testStringWithNoTokens {
    NSError *error;
    NSString *formatted = [NDPhraseParser formatStringWithPattern:@""
                                                          context:@{}
                                                         errorPtr:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(formatted, @"");
    formatted = [NDPhraseParser formatStringWithPattern:@""
                                                context:@{@"extra_data": @"this is unneeded",
                                                          @"more_arbitrary_data": @"also unneeded"}
                                               errorPtr:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(formatted, @"");
    formatted = [NDPhraseParser formatStringWithPattern:@"This is a string that needs no formatting"
                                                context:@{}
                                               errorPtr:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(formatted, @"This is a string that needs no formatting");
    formatted = [NDPhraseParser formatStringWithPattern:@"This is a string that needs no formatting"
                                                context:@{@"extra_data": @"this is unneeded",
                                                          @"more_arbitrary_data": @"also unneeded"}
                                               errorPtr:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(formatted, @"This is a string that needs no formatting");
}


- (void)testPhraseParserWithTokenAtBegining {
    NSError *error;
    NSString *formatted = [NDPhraseParser formatStringWithPattern:@"{token_one} is here"
                                                          context:@{@"token_one": @"1"}
                                                         errorPtr:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(formatted, @"1 is here");
}


- (void)testPhraseParserWithTokenInMiddle {
    NSError *error;
    NSString *formatted = [NDPhraseParser formatStringWithPattern:@"This is a {token_one} yeah it is"
                                                          context:@{@"token_one": @"string"}
                                                         errorPtr:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(formatted, @"This is a string yeah it is");
}


- (void)testPhraseParserWithTokenAtEnd {
    NSError *error;
    NSString *formatted = [NDPhraseParser formatStringWithPattern:@"This is a {token_one}"
                                                          context:@{@"token_one": @"string"}
                                                         errorPtr:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(formatted, @"This is a string");
}


- (void)testPhraseParserWithMultipleTokens {
    NSError *error;

    // 3 different tokens tokens
    NSString *s = @"This is a string with {token_one} and {token_two} {token_three}";
    NSString *formatted = [NDPhraseParser formatStringWithPattern:s
                                                          context:@{@"token_one": @"foo",
                                                                    @"token_two": @"bar",
                                                                    @"token_three": @"baz"}
                                                         errorPtr:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(formatted, @"This is a string with foo and bar baz");

    // 3 of the same token. Passing in extra data.
    formatted = [NDPhraseParser formatStringWithPattern:@"This is a string with {token_one} and {token_one} {token_one}"
                                                context:@{@"token_one": @"foo",
                                                          @"token_two": @"bar",
                                                          @"token_three": @"baz"}
                                               errorPtr:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(formatted, @"This is a string with foo and foo foo");
}


// Dealing with bad input

- (void)testTokenizingErrors {
    NSError *error;

    // Empty key
    NSString *formatted = [NDPhraseParser formatStringWithPattern:@"This has an empty {} token"
                                                          context:@{@"token_one": @"foo",
                                                                    @"token_two": @"bar",
                                                                    @"token_three": @"baz"}
                                                         errorPtr:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NDPhraseParserErrorCodeUnexpectedCharacter);
    XCTAssertNil(formatted);

    // No closing brace
    formatted = [NDPhraseParser formatStringWithPattern:@"This has {token_one} no closing {brace"
                                                context:@{@"token_one": @"foo",
                                                          @"token_two": @"bar",
                                                          @"token_three": @"baz"}
                                               errorPtr:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NDPhraseParserErrorCodeUnexpectedCharacter);
    XCTAssertNil(formatted);

    // Single lonely brace
    formatted = [NDPhraseParser formatStringWithPattern:@" {"
                                                context:@{}
                                               errorPtr:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NDPhraseParserErrorCodeUnexpectedCharacter);
    XCTAssertNil(formatted);
}


- (void)testFormattingErrors {
    NSError *error;

    // Not enough context
    NSString *formatted = [NDPhraseParser formatStringWithPattern:@"This has {some_tokens} and {not_enough_context}!"
                                                          context:@{@"some_other_token": @"blah"}
                                                         errorPtr:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NDPhraseParserErrorCodeMissingContext);
    XCTAssertNil(formatted);
}


// Escaping braces

- (void)testTwoLeftCurlyBracesFormatsAsSingleBrace {
    NSError *error;

    // Not enough context
    NSString *formatted = [NDPhraseParser formatStringWithPattern:@"{{"
                                                          context:@{}
                                                         errorPtr:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(formatted, @"{");

}


- (void)testIgnoresTokenNextToEscapedBrace {
    NSError *error;
    NSString *formatted = [NDPhraseParser formatStringWithPattern:@"hi {{name} {name}"
                                                          context:@{@"name": @"mcqueen"}
                                                         errorPtr:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(formatted, @"hi {name} mcqueen");
}


- (void)testCanEscapeCurlyBracesImmediatelyBeforeKey {
    NSError *error;
    NSString *formatted = [NDPhraseParser formatStringWithPattern:@"you are {{{name}"
                                                          context:@{@"name": @"mcqueen"}
                                                         errorPtr:&error];
    XCTAssertNil(error);
    XCTAssertEqualObjects(formatted, @"you are {mcqueen");
}


- (void)testKeyCannotStartWithUnderscore {
    NSError *error;
    NSString *formatted = [NDPhraseParser formatStringWithPattern:@"you are {_name}"
                                                          context:@{@"name": @"mcqueen"}
                                                         errorPtr:&error];
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, NDPhraseParserErrorCodeUnexpectedCharacter);
    XCTAssertNil(formatted);
}


- (void)testPassingNilError {
    NSString *nilString = [NDPhraseParser formatStringWithPattern:@"you are {name}"
                                                          context:@{@"name": @"mcqueen"}
                                                         errorPtr:nil];
    // No error passed in so this immediately returns as nil.
    XCTAssertNil(nilString);
}


- (void)testPassingNumbers {
    NSError *error;
    NSString *formattedWithNumber = [NDPhraseParser formatStringWithPattern:@"there are {num} apples"
                                                                    context:@{@"num": @4}
                                                                   errorPtr:&error];
    XCTAssertNil(error);

    NSString *formattedWithString = [NDPhraseParser formatStringWithPattern:@"there are {num} apples"
                                                                    context:@{@"num": @"4"}
                                                                   errorPtr:&error];
    XCTAssertNil(error);

    XCTAssertEqualObjects(formattedWithNumber, formattedWithString);
    XCTAssertEqualObjects(formattedWithNumber, @"there are 4 apples");
}


@end
