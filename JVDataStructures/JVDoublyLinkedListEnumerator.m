#import "JVDoublyLinkedListEnumerator.h"

@interface JVDoublyLinkedListEnumerator ()

@property (nonatomic, weak) JVDoublyLinkedNode *firstNode;
@property (nonatomic, weak) JVDoublyLinkedNode *currentNode;

@end

@implementation JVDoublyLinkedListEnumerator

#pragma Creating an Enumerator

+ (instancetype)enumeratorWithDoublyLinkedNode:(JVDoublyLinkedNode *)node {
	JVDoublyLinkedListEnumerator *enumerator = [[self alloc] initWithDoublyLinkedNode:node];

	return enumerator;
}

#pragma mark - Initializing an Enumerator

- (instancetype)initWithDoublyLinkedNode:(JVDoublyLinkedNode *)node {
	self = [self init];

	if(self) {
		self.firstNode = node;
	}

	return self;
}

#pragma mark - Querying the Enumerator

- (BOOL)hasNextObject {
	if(self.currentNode == nil) self.currentNode = self.firstNode;
	BOOL result = self.currentNode.next ? YES : NO;
	if(!result) self.firstNode = nil;

	return result;
}

#pragma mark - Getting the Enumerated Objects

- (NSArray *)allObjects {
	NSMutableArray *allObjects = [NSMutableArray new];

	while(self.currentNode != nil) {
		[allObjects addObject:[self nextObject]];
	}

	return allObjects;
}

- (id)currentObject {
	if(self.currentNode == nil) self.currentNode = self.firstNode;

	return self.currentNode.element;
}

- (id)nextObject {
	if(self.currentNode == nil) {
		self.currentNode = self.firstNode;
		// return self.currentNode.element;
	}

	// if(self.currentNode == self.firstNode) {
	// 	self.currentNode = self.currentNode.next;
	// 	return self.firstNode.element;
	// }
	
	JVDoublyLinkedNode *temp = self.currentNode;
	self.currentNode = self.currentNode.next;

	return temp.element;
}

- (id)previousObject {
	if(self.currentNode == nil) return nil;

	self.currentNode = self.currentNode.previous;
	
	return self.currentNode.element;
}

@end