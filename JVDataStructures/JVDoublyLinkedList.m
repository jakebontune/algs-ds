#import "JVDoublyLinkedList.h"
#import "JVDoublyLinkedNode.h"

@interface JVDoublyLinkedList ()

@property (nonatomic, strong) JVDoublyLinkedNode *head;
@property (nonatomic, strong) JVDoublyLinkedNode *tail;

@end

@implementation JVDoublyLinkedList

#pragma mark - Creating a Doubly Linked List

+ (instancetype)list {
	return [self new];
}

+ (instancetype)listWithObject:(id)anObject {
	return [[self alloc] initWithObject:anObject];
}

+ (instancetype)listWithArray:(NSArray *)array {
	return [[self alloc] initWithArray:array];
}

#pragma mark - Initializing a Doubly Linked List

- (instancetype)init {
	self = [super init];

	if(self) {
		_count = 0;
	}

	return self;
}

- (instancetype)initWithObject:(id)anObject {
	self = [self init];

	if (self) {
		JVDoublyLinkedNode *node = [JVDoublyLinkedNode nodeWithElement:anObject];
		self.head = node;
		self.tail = self.head;
		++_count;
	}

	return self;
}

- (instancetype)initWithArray:(NSArray *)array {
	self = [self init];

	if(self) {
		if(array[0] != nil) self.head = [JVDoublyLinkedNode nodeWithElement:array[0]];
		self.tail = self.head;
		JVDoublyLinkedNode *current = self.head, *previous = nil, *temp = nil;
		for (NSInteger i = 1; i < array.count; ++i) {
			temp = [JVDoublyLinkedNode nodeWithElement:array[i]];
			current.next = temp;
			current.previous = previous;
			previous = current;
			current = temp;

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

- (id)lastObject {
	return self.tail.element;
}

- (BOOL)isEmpty {
	if(_count == 0) return YES;
	
	return NO;
}

- (id)objectAtIndex:(NSUInteger)index {
	NSAssert(index < _count, @"Index %lu for query is out of bounds", index);

	JVDoublyLinkedNode *node = self.head;

	for (int i = 0; i < index; ++i) {
		node = node.next;
	}

	return node.element;
}

- (JVDoublyLinkedListEnumerator *)objectEnumerator {
	JVDoublyLinkedListEnumerator *enumerator = [JVDoublyLinkedListEnumerator enumeratorWithDoublyLinkedNode:self.head];
	return enumerator;
}

@end