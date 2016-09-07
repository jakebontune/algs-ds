//
// DoublyLinkedList.m
//

#import "DoublyLinkedList.h"
#import "../utilities/JLog.h"

// typedef enum {
// 	DLL_NEXT = 0,
// 	DLL_PREVIOUS
// } DLL_LINK;

@implementation DoublyLinkedList

// - (void)reverse {
// 	DNode *current = [self tail], *temp;

// 	while(current != nil) {
// 		current = [self swapNodeLinks:current returnLink:DLL_PREVIOUS];
// 	}

// 	temp = [self tail];
// 	[self setTail:self.head];
// 	[self setHead:temp];
// }

// - (void)recursiveReverse {
// 	DNode *tempHead = [self head], *temp;

// 	if([self.head next] == nil) {
// 		[self.head setNext:self.head.previous];
// 		[self.head setPrevious:nil];

// 		return;
// 	}

// 	[self setHead:self.head.next];

// 	[self recursiveReverse];

// 	temp = [tempHead previous];
// 	[tempHead setPrevious:tempHead.next];
// 	[tempHead setNext:temp];

// 	[self setTail:tempHead];
// }

// - (void)print {
// 	DNode *current = [self head];

// 	while(current != nil) {
// 		JLog(@"%i ", [current element]);
// 		current = [current next];
// 	}
// 	JLog(@"\n");
// }

// - (void) printRecursiveReverse: (DNode *)head {
// 	if(head == nil) {
// 		return;
// 	}
// 	[self printRecursiveReverse:[head next]];
// 	JLog(@"%i ", [head element]);
// }

// - (void)printReverse {
// 	[self printRecursiveReverse:[self head]];
// 	JLog(@"\n");
// }


// #pragma mark - Utility

// - (DNode *)swapNodeLinks: (DNode *)node returnLink: (DLL_LINK)link {
// 	if(link == DLL_PREVIOUS) {
// 		DNode *temp = [node previous];
// 		[node setPrevious:node.next];
// 		[node setNext:temp];
// 		return temp;
// 	} else {
// 		DNode *temp = [node next];
// 		[node setNext:node.previous];
// 		[node setPrevious:temp];
// 		return temp;
// 	}
// }

@end