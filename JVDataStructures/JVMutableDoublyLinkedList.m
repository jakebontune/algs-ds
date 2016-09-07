#import "JVMutableDoublyLinkedList.h"
#import "JVDoublyLinkedNode.h"
#import "../utilities/JLog.h"

@interface JVMutableDoublyLinkedList ()

@property (nonatomic, strong) JVDoublyLinkedNode *head;
@property (nonatomic, strong) JVDoublyLinkedNode *tail;

@end

@implementation JVMutableDoublyLinkedList

#pragma mark - Adding Objects

- (void)addObject:(id)anObject {
	[self insertObject:anObject atIndex:0];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
	NSAssert(index <= _count, @"Index %lu for insert is out of bounds", index);

	JVDoublyLinkedNode *newNode = [JVDoublyLinkedNode nodeWithElement:anObject];

	if(index == 0) {
		if (self.head == nil) {
			self.head = newNode;
			self.tail = newNode;
		} else {
			self.head.previous = newNode;
			newNode.next = self.head;
			self.head = newNode;
		}

		++_count;

		return;
	}

	if(index == _count) {
		self.tail.next = newNode;
		newNode.previous = self.tail;
		self.tail = newNode;

		++_count;

		return;
	}

	JVDoublyLinkedNode *target = self.head;

	for (int i = 0; i < index; ++i) {
		target = target.next;
	}

	target.previous.next = newNode;
	newNode.previous = target.previous;
	newNode.next = target;
	target.previous = newNode;

	++_count;
}

- (void)insertObjectAtEnd:(id)anObject {
	[self insertObject:anObject atIndex:_count];
}

#pragma mark - Removing Objects

- (void)removeFirstObject {
	[self removeObjectAtIndex:0];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
	NSAssert((index >= 0) && (index < _count), @"Index %lu for removal is out of bounds", index);

	JVDoublyLinkedNode *temp;

	if(index == 0) {
		if((self.head != nil) && (self.head.next != nil)) {
			temp = self.head.next;
			temp.previous = nil;
			self.head.next = nil;
			self.head = temp;
		} else { // zero or one element in the list
			self.head = nil;
			self.tail = nil;
		}

		--_count;

		return;
	}

	if(index == (_count - 1)) {
		temp = self.tail.previous;
		temp.next = nil;
		self.tail.previous = nil;
		self.tail = temp;

		--_count;

		return;
	}

	temp = self.head;

	for (int i = 0; i < index; ++i) {
		temp = temp.next;
	}

	temp.previous.next = temp.next;
	temp.next.previous = temp.previous;
	temp.previous = nil;
	temp.next = nil;

	--_count;
}

- (void)removeLastObject {
	[self removeObjectAtIndex:_count - 1];
}

#pragma mark - Replacing Objects

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
	NSAssert((index >= 0) && (index < _count), @"Index %lu for replacement is out of bounds", index);

	JVDoublyLinkedNode *target = self.head;

	for (int i = 0; i < index; ++i) {
		target = target.next;
	}

	target.element = anObject;
}

#pragma mark - TESTING

- (void)print {
	JVDoublyLinkedNode *current = [self head];

	while(current != nil) {
		JLog(@"%d ", [[current element] intValue]);
		current = [current next];
	}
	JLog(@"\n");
}

- (void) printRecursiveReverse:(JVDoublyLinkedNode *)head {
	if(head == nil) {
		return;
	}
	[self printRecursiveReverse:[head next]];
	JLog(@"%d ", [[head element] intValue]);
}

- (void)printReverse {
	[self printRecursiveReverse:[self head]];
	JLog(@"\n");
}

@end









