#import "JVLinearNode.h"

@implementation JVLinearNode

#pragma mark - Creating a Node

+ (instancetype)nodeWithElement:(id)element {
	JVLinearNode *node = [[self alloc] initWithElement:element];

	return node;
}

#pragma mark - Initializing a Node

- (instancetype)initWithElement:(id)element {
	self = [super init];

	if(self) {
		[self setElement:element];
	}

	return self;
}

@end