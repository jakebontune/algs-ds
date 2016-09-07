#import <Foundation/Foundation.h>
#import "JVLinearNode.h"

@interface JVDoublyLinkedNode : JVLinearNode

@property (nonatomic, strong) JVDoublyLinkedNode *next;
@property (nonatomic, strong) JVDoublyLinkedNode *previous;

@end