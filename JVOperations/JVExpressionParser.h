#import <Foundation/Foundation.h>

@interface JVExpressionParser : NSObject

- (NSInteger)parsePostfixExpression:(NSString *)expression;
- (NSInteger)parsePrefixExpression:(NSString *)expression;
- (NSString *)convertInfixToPostfix:(NSString *)expression;

@end