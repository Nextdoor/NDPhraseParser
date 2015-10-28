//
//  NDPhraseParser.m
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

#import "NDPhraseParser.h"


NSString *const NDPhraseParserErrorDomain = @"com.nextdoor.NDPhraseParser";

/**
 *  Represents a general parsed object for the given pattern.
 */
@interface NDToken : NSObject

/**
 *  A pattern is represented as a doubly linked list of Tokens.
 */
@property (nonatomic, strong) NDToken *previous;
@property (nonatomic, strong) NDToken *next;

/**
 *  NS_DESIGNATED_INITIALIZER
 *
 *  @param previous The token before this one in the linked list.
 *
 *  @return An instance of this class.
 */
- (instancetype)initWithPrevious:(NDToken *)previous NS_DESIGNATED_INITIALIZER;

/**
 *  Methods for determining where this token exists within the pattern. Useful for
 *  NSMakeRange during actual string replacement.
 */
- (NSUInteger)getFormattedStart;
- (NSUInteger)getFormattedLength;

/**
 *  Replace this token with its final value in the formatted string.
 *
 *  @param target The formatted string, in some state of being formatted.
 *  @param data   A dictionary of data for expanding (in practice, the context dictionary).
 */
- (void)expand:(NSMutableString *)target withData:(NSDictionary *)data;

@end

/**
 *  Represents a parsed section of text that does not contain a key. i.e. just
 *  some regular text within the pattern.
 */
@interface NDTextToken : NDToken

/**
 *  The length of this piece of text.
 */
@property (nonatomic, assign) NSUInteger length;

- (instancetype)initWithPrevious:(NDToken *)previous andLength:(NSUInteger)length;

@end

/**
 *  Represents a parsed left brace '{'.
 *
 *  This token type is special because we need it to allow for escaping braces.
 */
@interface NDLeftBraceToken : NDToken

@end

/**
 *  Represents a parsed key within a pattern. i.e. the piece of text we will be
 *  replacing: "{this_is_a_key}"
 */
@interface NDKeyToken : NDToken

@property (nonatomic, strong) NSString *key;

/**
 *  The value we will be replacing this token with. Note that this value does not
 *  exist until context is applied! We do not initialize this object with a value.
 */
@property (nonatomic, strong) NSString *value;

/**
 *  Standard Token initializer, with key name.
 */
- (instancetype)initWithPrevious:(NDToken *)previous key:(NSString *)key;

@end


@interface NDPhraseParser ()

/**
 *  The pattern to format. (i.e. @"this is a string with {key_number_one}")
 */
@property (nonatomic, strong) NSString *pattern;

/**
 *  A set of strings representing the context that is required to format
 *  the pattern. We don't know this until after we have tokenized the pattern.
 *
 *  This is used to make sure that we are fully formatting a string. Failing to
 *  pass in all the context that is required results in an error.
 */
@property (nonatomic, strong) NSMutableSet *requiredContext;

/**
 *  Character positioning within the pattern, as we tokenize.
 */
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign) unichar currentChar;

/**
 *  The head of the doubly linked list of Tokens.
 */
@property (nonatomic, strong) NDToken *head;

/**
 *  NS_DESIGNATED_INITIALIZER
 *
 *  @param pattern The pattern to format (i.e. @"this is a string with {key_number_one}")
 *
 *  @return An instance of this class.
 */
- (instancetype)initWithPattern:(NSString *)pattern NS_DESIGNATED_INITIALIZER;

/**
 *  Create a doubly linked list of NDTokens from the pattern.
 *
 *  @param error A pointer to a pointer to an error that will get set if tokenization goes wrong.
 */
- (void)tokenize:(NSError **)error;

/**
 *  Expand the list of tokens into a fully formatted string.
 *
 *  @param context A dictionary of context to format with, strings mapped to strings.
 *                 (i.e. @{"key_number_one": "1 string value"})
 *  @param error   A pointer to a pointer to an error. Gets set if something goes wrong.
 *
 *  @return An instance of this class.
 */
- (NSString *)formatWithContext:(NSDictionary *)context errorPtr:(NSError **)error;

@end

@implementation NDPhraseParser

#pragma mark - Initialization

- (instancetype)initWithPattern:(NSString *)pattern  {
    self = [super init];
    if (self) {
        _pattern = pattern;
        _requiredContext = [NSMutableSet set];
        _currentChar = (_pattern.length > 0) ? [_pattern characterAtIndex:0] : 0;
    }
    return self;
}


#pragma mark - Public methods

+ (NSString *)formatStringWithPattern:(NSString *)pattern
                              context:(NSDictionary *)context
                             errorPtr:(NSError **)error {
    if (!error) {
        return nil;
    }

    NDPhraseParser *parser = [[NDPhraseParser alloc] initWithPattern:pattern];
    [parser tokenize:error];
    if (*error) {
        return nil;
    }

    NSString *formatted = [parser formatWithContext:context errorPtr:error];
    if (*error) {
        return nil;
    }

    return formatted;
}


#pragma mark - Private methods

/**
 *  Step 1.
 */
- (void)tokenize:(NSError **)error {
    NDToken *previous = nil;
    NDToken *next = [self createNextToken:previous errorPtr:error];

    // Build a doubly linked list of valid Tokens.
    while (next != nil) {
        if (self.head == nil) {
            self.head = next;
        }
        previous = next;
        next = [self createNextToken:previous errorPtr:error];
    }
}


/**
 *  Step 2.
 */
- (NSString *)formatWithContext:(NSDictionary *)context
                       errorPtr:(NSError **)error {

    // Silently coerce all context values into strings. This allows us to pass NSNumbers and
    // other common objects seamlessly as if they were strings.
    NSMutableDictionary *adjustedContext = [[NSMutableDictionary alloc] init];
    for (NSString *key in [context allKeys]) {
        adjustedContext[key] = [context[key] description];
    }

    NSSet *givenContext = [NSSet setWithArray:[adjustedContext allKeys]];
    NSMutableSet *requiredContext = [self.requiredContext mutableCopy];
    [requiredContext minusSet:givenContext];
    if (requiredContext.count != 0) {
        *error = [NSError errorWithDomain:NDPhraseParserErrorDomain
                                     code:NDPhraseParserErrorCodeMissingContext
                                 userInfo:@{NSLocalizedDescriptionKey: @"Missing context",
                                            @"Context needed": requiredContext}];
        return nil;
    }

    NSMutableString *formattedStr = [[NSMutableString alloc] initWithString:self.pattern];
    NDToken *token = self.head;
    while (token != nil) {
        [token expand:formattedStr withData:adjustedContext];
        token = token.next;
    }

    return formattedStr;
}


- (NDToken *)createNextToken:(NDToken *)previous errorPtr:(NSError **)error {
    if (self.currentChar == 0) {
        // We have reached the end of the pattern, return.
        return nil;
    }

    if (self.currentChar == '{') {
        // Error checking and handling of consecutive '{{' left braces:
        unichar nextChar = [self lookAhead];
        if (nextChar == '{') {
            return [self createLeftBraceToken:previous];
        } else if (nextChar >= 'a' && nextChar <= 'z') {
            return [self createKeyToken:previous errorPtr:error];
        } else {
            NSString *unexpectedCharStr = [NSString stringWithFormat:@"%C", nextChar];
            *error = [NSError errorWithDomain:NDPhraseParserErrorDomain
                                         code:NDPhraseParserErrorCodeUnexpectedCharacter
                                     userInfo:@{NSLocalizedDescriptionKey: @"Expected key, got unexpected character",
                                                @"Unexpected character": unexpectedCharStr}];
            return nil;
        }
    }

    return [self createTextToken:previous];
}


- (NDKeyToken *)createKeyToken:(NDToken *)previous errorPtr:(NSError **)error {
    // consume the '{'
    [self consumeOneCharacter];

    NSMutableString *key = [[NSMutableString alloc] init];
    while ((self.currentChar >= 'a' && self.currentChar <= 'z') || self.currentChar == '_') {
        // Consume while characters are valid. Append to the result string.
        [key appendString:[NSString stringWithFormat:@"%C", self.currentChar]];
        [self consumeOneCharacter];
    }

    if (self.currentChar != '}') {
        *error = [NSError errorWithDomain:NDPhraseParserErrorDomain
                                     code:NDPhraseParserErrorCodeUnexpectedCharacter
                                 userInfo:@{NSLocalizedDescriptionKey: @"Missing closing brace '}' in pattern."}];

        return nil;
    }

    // consume the '}'
    [self consumeOneCharacter];

    if (key.length == 0) {
        *error = [NSError errorWithDomain:NDPhraseParserErrorDomain
                                     code:NDPhraseParserErrorCodeUnexpectedCharacter
                                 userInfo:@{NSLocalizedDescriptionKey: @"Empty key '{}' in pattern."}];
        return nil;
    }

    // Mark this key as required to format correctly.
    [self.requiredContext addObject:key];
    return [[NDKeyToken alloc] initWithPrevious:previous key:key];
}


- (NDLeftBraceToken *)createLeftBraceToken:(NDToken *)previous {
    // Consume 2 characters and return a token representing 2 consecutive left braces.
    [self consumeOneCharacter];
    [self consumeOneCharacter];
    return [[NDLeftBraceToken alloc] initWithPrevious:previous];
}


- (NDTextToken *)createTextToken:(NDToken *)previous {
    NSUInteger startIndex = self.currentIndex;
    while (self.currentChar != '{' && self.currentChar != 0)
        [self consumeOneCharacter];
    return [[NDTextToken alloc] initWithPrevious:previous
                                       andLength:self.currentIndex - startIndex];
}


/**
 *  Returns the next character without advancing.
 */
- (unichar)lookAhead {
    if (self.currentIndex < self.pattern.length - 1) {
        return [self.pattern characterAtIndex:self.currentIndex + 1];
    } else {
        return 0;
    }
}


/**
 *  Advances the current character position without any error checking. We can only
 *  hit the end of the string if this parser contains a bug.
 */
- (void)consumeOneCharacter {
    self.currentIndex++;
    self.currentChar =
    (self.currentIndex == self.pattern.length) ? 0 : [self.pattern characterAtIndex:self.currentIndex];
}


@end


@implementation NDToken

#pragma mark - Initialization

- (instancetype)initWithPrevious:(NDToken *)previous {
    self = [super init];
    if (self) {
        _previous = previous;
        _previous.next = self;
    }
    return self;
}


#pragma mark - Public methods

- (NSUInteger)getFormattedStart {
    if (self.previous == nil) {
        return 0U;
    } else {
        return [self.previous getFormattedStart] + [self.previous getFormattedLength];
    }
}


- (NSUInteger)getFormattedLength {
    NSCAssert(NO, @"Must be overriden in subclass.");
    return NSNotFound;
}


- (void)expand:(NSMutableString *)target withData:(NSDictionary *)data {
    NSCAssert(NO, @"Must be overriden in subclass.");
}


@end


@implementation NDTextToken

#pragma mark - Initialization

- (instancetype)initWithPrevious:(NDToken *)previous andLength:(NSUInteger)length {
    self = [super initWithPrevious:previous];
    if (self) {
        _length = length;
    }
    return self;
}


#pragma mark - Public methods

- (NSUInteger)getFormattedLength {
    return self.length;
}


- (void)expand:(NSMutableString *)target withData:(NSDictionary *)data {
    // Don't alter spans in the target.
}


@end


@implementation NDLeftBraceToken

#pragma mark - Public methods

- (NSUInteger)getFormattedLength {
    return 1;
}


- (void)expand:(NSMutableString *)target withData:(NSDictionary *)data {
    NSRange replaceRange = NSMakeRange([self getFormattedStart], 2);  // add 2 for braces
    [target setString:[target stringByReplacingCharactersInRange:replaceRange withString:@"{"]];
}


@end


@implementation NDKeyToken

#pragma mark - Initialization

- (instancetype)initWithPrevious:(NDToken *)previous key:(NSString *)key {
    self = [super initWithPrevious:previous];
    if (self) {
        _key = key;
    }
    return self;
}


#pragma mark - Public methods

- (NSUInteger)getFormattedLength {
    // Note that value is only present after expand.
    // Don't error check because this is all private code.
    return self.value.length;
}


- (void)expand:(NSMutableString *)target withData:(NSDictionary *)data {
    self.value = data[self.key];
    NSRange replaceRange = NSMakeRange([self getFormattedStart], self.key.length + 2);  // add 2 for braces
    [target setString:[target stringByReplacingCharactersInRange:replaceRange withString:self.value]];
}


@end
