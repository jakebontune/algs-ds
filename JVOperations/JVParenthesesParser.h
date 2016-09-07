#import <Foundation/Foundation.h>

@interface JVParenthesesParser : NSObject

- (BOOL)checkParenthesesInString:(NSString *)string;
- (BOOL)parenthesisIsMatch:(unichar)pA with:(unichar)pB;

@end