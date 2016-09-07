#import "JVSinglyLinkedList.h"
#import "JVSinglyLinkedNode.h"
#import "JVBlockEnumerator.h"

@interface JVSinglyLinkedList ()

@property (nonatomic, strong) JVSinglyLinkedNode *head;

@end

@implementation JVSinglyLinkedList

#pragma mark - Creating a Singly Linked List

+ (instancetype)list {
	return [self new];
}

+ (instancetype)listWithObject:(id)anObject {
	return [[self alloc] initWithObject:anObject];
}

+ (instancetype)listWithArray:(NSArray *)array {
	return [[self alloc] initWithArray:array];
}

#pragma mark - Initializing a Singly Linked List

- (instancetype)init {
	self = [super init];
	return self;
}

- (instancetype)initWithObject:(id)anObject {
	self = [self init];

	if (self) {
		_count = 0;
		JVSinglyLinkedNode *node = [JVSinglyLinkedNode nodeWithElement:anObject];
		self.head = node;
		++_count;
	}

	return self;
}

- (instancetype)initWithArray:(NSArray *)array {
	self = [self init];

	if(self) {
		if(array[0] != nil) self.head = [JVSinglyLinkedNode nodeWithElement:array[0]];
		JVSinglyLinkedNode *current = nil;
		JVSinglyLinkedNode *temp = self.head;
		for (NSInteger i = 1; i < array.count; ++i) {
			current = [JVSinglyLinkedNode nodeWithElement:array[i]];
			temp.next = current;
			temp = current;
			++_count;
		}
	}

	return self;
}

#pragma mark - Querying a List

- (NSUInteger)count {
	return _count;
}

- (id)firstObject {
	return self.head.element;
}

- (BOOL)isEmpty {
	if(_count == 0) return YES;
	
	return NO;
}

- (id)objectAtIndex:(NSUInteger)index {
	NSAssert(index < _count, @"Index %lu for query is out of bounds", index);

	JVSinglyLinkedNode *node = self.head;

	for (int i = 0; i < index; ++i) {
		node = node.next;
	}

	return node.element;
}

- (NSEnumerator *)objectEnumerator {
	__block JVSinglyLinkedNode *temp = self.head;

	NSEnumerator *enumerator = [[JVBlockEnumerator alloc] initWithBlock:^{
		JVSinglyLinkedNode *node = temp;
		temp = [temp next];
		return node.element;
	}];

	return enumerator;
}

@end









