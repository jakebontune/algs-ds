#import "JVStack.h"
#import "JVMutableSinglyLinkedList.h"

@interface JVStack ()

@property (nonatomic, strong) JVMutableSinglyLinkedList *list;

@end

@implementation JVStack

#pragma mark - Creating a Stack

+ (instancetype)stack {
	JVStack *stack = [[JVStack alloc] init];
	
	return stack;
}

+ (instancetype)stackWithElement:(id)element {
	JVStack *stack = [[JVStack alloc] initWithElement:element];

	return stack;
}

#pragma mark - Initializing a Stack

- (instancetype)init {
	self = [super init];

	if(self) self.list = [[JVMutableSinglyLinkedList alloc] init];
	
	return self;
}

- (instancetype)initWithElement:(id)element {
	self = [self init];

	if(self) [self.list addObject:element];

	return self;
}

#pragma mark - Querying a Stack

- (void)push:(id)element {
	[self.list addObject:element];
}

- (id)pop {
	// NSAssert([self.list count] != 0, @"Popped out of bounds");
	if(self.list.count == 0) return nil;
	id popped = [self.list firstObject];
	[self.list removeFirstObject];

	return popped;
}

- (id)peek {
	// NSAssert([self.list count] != 0, @"Peeked out of bounds");
	if(self.list.count == 0) return nil;
	return [self.list firstObject];
}

- (BOOL)isEmpty {
	return [self.list count] == 0 ? YES : NO;
}

- (NSUInteger)count {
	return [self.list count];
}

@end
