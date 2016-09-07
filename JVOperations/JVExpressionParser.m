#import "JVExpressionParser.h"
#import "JVParenthesesParser.h"
#import "../JVDataStructures/JVStack.h"

@interface JVExpressionParser () {
@private
	JVStack<NSNumber *> *_stack;
	NSCharacterSet *_digitSet;
	NSCharacterSet *_alphanumeric;
	NSCharacterSet *_operatorSet;
	NSCharacterSet *_openParenthesisSet;
	NSCharacterSet *_closingParenthesisSet;
	JVParenthesesParser *_pp;
}

@end

@implementation JVExpressionParser

- (instancetype)init {
	if(self = [super init]) {
		_stack = [JVStack stack];
		_digitSet = [NSCharacterSet decimalDigitCharacterSet];
		_alphanumeric = [NSCharacterSet letterCharacterSet];
		_operatorSet = [NSCharacterSet characterSetWithCharactersInString:@"+-*/%%^"];
		_openParenthesisSet = [NSCharacterSet characterSetWithCharactersInString:@"{[("];
		_closingParenthesisSet = [NSCharacterSet characterSetWithCharactersInString:@"}])"];
		_pp = [JVParenthesesParser new];
	}

	return self;
}

- (NSInteger)parsePostfixExpression:(NSString *)expression {
	// NSCharacterSet *digitSet = [NSCharacterSet decimalDigitCharacterSet];
	// NSCharacterSet *operatorSet = [NSCharacterSet characterSetWithCharactersInString:@"+-*/^"];
	NSInteger op1;
	NSInteger op2;
	NSNumber *temp;

	for (int i = 0; i < expression.length; ++i) {
		if(![_stack isEmpty] && [_operatorSet characterIsMember:[expression characterAtIndex:i]]) {
			op2 = [[_stack pop] integerValue];
			op1 = [[_stack pop] integerValue];
			temp = [NSNumber numberWithInteger:[self performOperationWithLeftOperand:op1 rightOperand:op2 operator:(char)[expression characterAtIndex:i]]];
			[_stack push:temp];
		} else if([_digitSet characterIsMember:[expression characterAtIndex:i]]) {
			[_stack push:[NSNumber numberWithInt:([expression characterAtIndex:i] - '0')]];
		} else {
			[NSException raise:NSInvalidArgumentException format:@"-[%@ %s] %s:%d invalid expression %@", [self class], sel_getName(_cmd), __FILE__, __LINE__, expression];
		}
	}

	return [[_stack pop] integerValue];
}

- (NSInteger)parsePrefixExpression:(NSString *)expression {
	NSInteger op1;
	NSInteger op2;
	NSNumber *temp;

	for (int i = expression.length - 1; i >= 0; --i) {
		if(![_stack isEmpty] && [_operatorSet characterIsMember:[expression characterAtIndex:i]]) {
			op1 = [_stack pop].integerValue;
			op2 = [_stack pop].integerValue;
			temp = [NSNumber numberWithInteger:[self performOperationWithLeftOperand:op1 rightOperand:op2 operator:(char)[expression characterAtIndex:i]]];
			[_stack push:temp];
		} else if([_digitSet characterIsMember:[expression characterAtIndex:i]]) {
			[_stack push:[NSNumber numberWithInt:([expression characterAtIndex:i] - '0')]];
		} else {
			[NSException raise:NSInvalidArgumentException format:@"-[%@ %s] %s:%d invalid expression %@", [self class], sel_getName(_cmd), __FILE__, __LINE__, expression];
		}
	}

	return [[_stack pop] integerValue];
}

- (NSString *)convertInfixToPostfix:(NSString *)expression {
	NSMutableString *result = [NSMutableString stringWithString:@""];
	JVStack<NSString *> *tempStack = [JVStack stack];

	for (int i = 0; i < expression.length; ++i) {
		if([_alphanumeric characterIsMember:[expression characterAtIndex:i]]) {
			[result appendString:[NSString stringWithFormat:@"%C", [expression characterAtIndex:i]]];
		}

		if([_operatorSet characterIsMember:[expression characterAtIndex:i]]) {
			while(![tempStack isEmpty] && ![_openParenthesisSet characterIsMember:[[tempStack peek] characterAtIndex:0]] && [self operatorHasHigherPrecedence:[[tempStack peek] characterAtIndex:0] than:(char)[expression characterAtIndex:i]]) {
				[result appendString:[tempStack pop]];
			}
			[tempStack push:[NSString stringWithFormat:@"%C", [expression characterAtIndex:i]]];
		}

		if([_openParenthesisSet characterIsMember:[expression characterAtIndex:i]]) [tempStack push:[NSString stringWithFormat:@"%C", [expression characterAtIndex:i]]];

		if([_closingParenthesisSet characterIsMember:[expression characterAtIndex:i]]) {
			while(!tempStack.isEmpty && ![_openParenthesisSet characterIsMember:[[tempStack peek] characterAtIndex:0]]) {
				[result appendString:[tempStack pop]];
			}

			if(![_pp parenthesisIsMatch:[[tempStack pop] characterAtIndex:0] with:[expression characterAtIndex:i]]) {
				[NSException raise:NSInvalidArgumentException format:@"-[%@ %s] %s:%d invalid expression %@", [self class], sel_getName(_cmd), __FILE__, __LINE__, expression];
			}
		}
	}

	while(![tempStack isEmpty]) {
		NSString *temp = [tempStack pop];
		if(![_openParenthesisSet characterIsMember:[temp characterAtIndex:0]] && ![_closingParenthesisSet characterIsMember:[temp characterAtIndex:0]]) {
			[result appendString:temp];
		} else {
			[NSException raise:NSInvalidArgumentException format:@"-[%@ %s] %s:%d invalid expression %@", [self class], sel_getName(_cmd), __FILE__, __LINE__, expression];
		}
	}

	return result;
}

- (NSInteger)performOperationWithLeftOperand:(NSInteger)op1 rightOperand:(NSInteger)op2 operator:(char)operator {
	NSLog(@"%s(%ld, %ld, %c)", sel_getName(_cmd), op1, op2, operator);
	switch (operator) {
		case '+':
			return op1 + op2;
			break;
		case '-':
			return op1 - op2;
			break;
		case '*':
			return op1 * op2;
			break;
		case '/':
			return op1 / op2;
			break;
		case '%':
			return op1 % op2;
			break;
		case '^':
			return pow(op1, op2);
			break;
		default:
			return 0;
	}
}

- (BOOL)operatorHasHigherPrecedence:(char)op1 than:(char)op2 {
	NSArray *operators = @[@"-", @"+", @"/", @"*", @"%%", @"^"];
	if([operators indexOfObject:[NSString stringWithFormat:@"%c", op1]] > [operators indexOfObject:[NSString stringWithFormat:@"%c", op2]]) {
		return YES;
	} else {
		return NO;
	}
}

@end