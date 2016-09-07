#import "JVLinkedList.h"
#import "../utilities/JLogic.h"
#import "../utilities/JLog.h"

@interface JVLinkedList ()

@end

@implementation JVLinkedList

// - (void)reverse {
// 	SNode *current = [self head], *previous = nil, *next = nil;

// 	while([current next] != nil) {
// 		next = [current next];
// 		[current setNext:previous];
// 		previous = current;
// 		current = next;
// 	}

// 	[current setNext:previous];
// 	[self setHead:current];
// }

// - (void)recursiveReverse {
// 	SNode *tempHead = [self head], *tempNext = [tempHead next];

// 	if([tempNext next] == nil) {
// 		[tempNext setNext:tempHead];
// 		self.head = tempNext;
// 		return;
// 	}
// 	[self setHead:tempNext];
// 	[self recursiveReverse];
// 	[tempNext setNext:tempHead];
// 	[tempHead setNext:nil];
// }

// - (void)print {
// 	SNode *current = [self head];

// 	while(current != nil) {
// 		JLog(@"%d ", [current element]);
// 		current = [current next];
// 	}
// 	JLog(@"\n");
// }

// - (void) printRecursiveReverse: (SNode *)head {
// 	if(head == nil) {
// 		return;
// 	}
// 	[self printRecursiveReverse:[head next]];
// 	JLog(@"%d ", [head element]);
// }

// - (void)printReverse {
// 	[self printRecursiveReverse: [self head]];
// 	JLog(@"\n");
// }

@end