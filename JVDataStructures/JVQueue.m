#import "JVQueue.h"
#import "JVMutableDoublyLinkedList.h"

@interface JVQueue ()

@end

@implementation JVQueue {
	JVMutableDoublyLinkedList *_list;
}

#pragma mark - Creating a Queue

+ (instancetype)queue {
	return [[JVQueue alloc] init];
}

+ (instancetype)queueWithElement:(id)element {
	return [[JVQueue alloc] initWithElement:element];
}

#pragma mark - Initializing a Queue

- (instancetype)init {
	self = [super init];

	if(self) _list = [[JVMutableDoublyLinkedList alloc] init];

	return self;
}

- (instancetype)initWithElement:(id)element {
	self = [self init];

	if(self) [_list addObject:element];

	return self;
}

#pragma mark - Querying a Queue

- (void)enqueue:(id)element {
	[_list addObject:element];
}

- (id)dequeue {
	// NSAssert(_list.count != 0, @"Dequeued out of bounds");
	if(_list.count == 0) return nil;
	id dequeued = _list.lastObject;
	[_list removeLastObject];

	return dequeued;
}

- (id)peek {
	return _list.firstObject;
}

- (NSUInteger)count {
	return _list.count;
}

- (BOOL)isEmpty {
	return _list.count == 0 ? YES : NO;
}

@end
