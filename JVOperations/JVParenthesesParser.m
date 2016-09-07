#import "JVParenthesesParser.h"
#import "../JVDataStructures/JVStack.h"

@interface JVParenthesesParser ()
@property (nonatomic, strong) JVStack<NSString *> *stack;
@end

@implementation JVParenthesesParser

- (instancetype)init {
	if(self = [super init]) self.stack = [JVStack stack];

	return self;
}

- (BOOL)checkParenthesesInString:(NSString *)string {
	// NSString *opening = @"{[(";
	// NSString *closing = @"}])";
	NSCharacterSet *openingSet = [NSCharacterSet characterSetWithCharactersInString:@"{[("];
	NSCharacterSet *closingSet = [NSCharacterSet characterSetWithCharactersInString:@"}])"];
	NSString *cParentheses;
	for (int i = 0; i < string.length; ++i) {
		cParentheses = [NSString stringWithFormat:@"%C", [string characterAtIndex:i]];
		// NSLog(@"cParentheses: %C", [string characterAtIndex:i]);
		if([openingSet characterIsMember:[string characterAtIndex:i]]) {
			[self.stack push:cParentheses];
		} else if([self.stack isEmpty] || ([closingSet characterIsMember:[string characterAtIndex:i]] && ![self parenthesisIsMatch:[string characterAtIndex:i] with:[[self.stack pop] characterAtIndex:0]])) {
			return NO;
		}
	}

	return YES;
}

- (BOOL)parenthesisIsMatch:(unichar)pA with:(unichar)pB {
	BOOL result = NO;

	switch(pA) {
		case '}':
			if(pB == '{') result = YES;
			break;
		case '{':
			if(pB == '}') result = YES;
			break;
		case ')':
			if(pB == '(') result = YES;
			break;
		case '(':
			if(pB == ')') result = YES;
			break;
		case ']':
			if(pB == '[') result = YES;
			break;
		case '[':
			if(pB == ']') result = YES;
			break;
		default:
			result = NO;
	}

	return result;
}

@end