#import "JVMutableSinglyLinkedList.h"
#import "JVSinglyLinkedNode.h"
#import "../utilities/JLog.h"

@interface JVMutableSinglyLinkedList ()

@property (nonatomic, strong) JVSinglyLinkedNode *head;

@end

@implementation JVMutableSinglyLinkedList

#pragma mark - Adding Objects

- (void)addObject:(id)anObject {
	[self insertObject:anObject atIndex:0];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
	NSAssert(index <= _count, @"Index %lu for insert is out of bounds", index);

	JVSinglyLinkedNode *newNode = [JVSinglyLinkedNode nodeWithElement:anObject];

	if(index == 0) {
		if (self.head == nil) {
			self.head = newNode;

			++_count;

			return;
		}

		newNode.next = self.head;
		self.head = newNode;

		++_count;

		return;
	}

	JVSinglyLinkedNode *leftNode = self.head;

	if(index == _count) {
		while(leftNode.next != nil) {
			leftNode = leftNode.next;
		}

		leftNode.next = newNode;

		++_count;

		return;
	}

	for (int i = 0; i < index - 1; ++i) {
		leftNode = leftNode.next;
	}

	newNode.next = leftNode.next;
	leftNode.next = newNode;

	++_count;
}

- (void)insertObjectAtEnd:(id)anObject {
	[self insertObject:anObject atIndex:_count];
}

#pragma mark - Removing Objects

- (void)removeFirstObject {
	[self removeObjectAtIndex:0];
}

- (void)removeObject:(id)anObject {
	JVSinglyLinkedNode *target = self.head;
	JVSinglyLinkedNode *temp;
	NSUInteger index;

	while(index < _count) {
		if([target isEqualTo:self.head]) {
			temp = target.next;
			target.next = nil;
			self.head = temp;
		} else if((target.next.next = nil) && ([target.next.element isEqualTo:anObject])) {
			target.next = nil;
		} else if([target.next.element isEqualTo:anObject]) {
			temp = target.next.next;
			target.next.next = nil;
			target.next = temp;
		}
		
		target = [target next];
		++index;
	}
}

- (void)removeObjectAtIndex:(NSUInteger)index {
	NSAssert((index >= 0) && (index < _count), @"Index %lu for removal is out of bounds", index);

	JVSinglyLinkedNode *temp;

	if(index == 0) {
		temp = self.head.next;
		self.head.next = nil;
		self.head = temp;

		--_count;

		return;
	}

	JVSinglyLinkedNode *target;
	temp = self.head;

	for (int i = 0; i < index - 1; ++i) {
		temp = temp.next;
	}

	target = temp.next;
	temp.next = target.next;
	target.next = nil;

	--_count;
}

- (void)removeLastObject {
	[self removeObjectAtIndex:_count - 1];
}

#pragma mark - Replacing Objects

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
	NSAssert((index >= 0) && (index < _count), @"Index %lu for replacement is out of bounds", index);

	JVSinglyLinkedNode *target = self.head;

	for (int i = 0; i < index; ++i) {
		target = target.next;
	}

	target.element = anObject;
}

#pragma mark - TESTING

- (void)print {
	JVSinglyLinkedNode *current = [self head];

	while(current != nil) {
		JLog(@"%d ", [[current element] intValue]);
		current = [current next];
	}
	JLog(@"\n");
}

- (void) printRecursiveReverse:(JVSinglyLinkedNode *)head {
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









