#import <Foundation/Foundation.h>
#import "JVDoublyLinkedNode.h"

@class JVDoublyLinkedList;

@interface JVDoublyLinkedListEnumerator<ElementType> : NSObject

@property (readonly, copy) NSArray<ElementType> *allObjects;
- (instancetype)initWithDoublyLinkedNode:(JVDoublyLinkedNode *)node;
+ (instancetype)enumeratorWithDoublyLinkedNode:(JVDoublyLinkedNode *)node;
- (BOOL)hasNextObject;
- (ElementType)currentObject;
- (ElementType)nextObject;
- (ElementType)previousObject;

@end