#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import "JVBinarySearchTree.h"
#import "JVQueue.h"
#import "JVBlockEnumerator.h"

/****************   Binary Tree Node    ****************/

@interface JVBinaryTreeNode<ElementType> : NSObject

NS_ASSUME_NONNULL_BEGIN

@property (nullable, nonatomic, strong) JVBinaryTreeNode *left;
@property (nullable, nonatomic, strong) JVBinaryTreeNode *right;
@property (nonatomic, strong) ElementType element;

- (instancetype)initWithElement:(ElementType)element;
+ (instancetype)nodeWithElement:(ElementType)element;

@end

NS_ASSUME_NONNULL_END

@implementation JVBinaryTreeNode {
 @private
  id _element;
}

#pragma mark - Creating a Binary Tree Node

+ (instancetype)nodeWithElement:(id)element {
    return [[JVBinaryTreeNode alloc] initWithElement:element];
}

#pragma mark - Initializing a Binary Tree Node

- (instancetype)initWithElement:(id)element {
    if(self = [self init]) _element = element;
    return self;
}

- (id)element {
    return _element;
}

@end


/****************   Binary Search Tree ****************/

@interface JVBinarySearchTree ()

@end

@implementation JVBinarySearchTree {
    JVBinaryTreeNode *_rootNode;
    NSComparator _comparator;
    NSUInteger _count;
}

#pragma mark - Creating a Binary Tree

+ (instancetype)tree {
    return [[JVBinarySearchTree alloc] init];
}

+ (instancetype)treeWithObject:(id)anObject {
    return [[JVBinarySearchTree alloc] initWithObject:anObject];
}

+ (instancetype)treeWithObject:(id)anObject comparator:(NSComparator)comparator {
    return [[JVBinarySearchTree alloc] initWithObject:anObject comparator:comparator];
}

#pragma mark - Initializing a Binary Tree

- (instancetype)init {
    if(self = [super init]) {
        _comparator = ^(NSNumber *obj1, NSNumber *obj2) {
            if(obj1 > obj2) {
                return (NSComparisonResult)NSOrderedDescending;
            } else if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }
        };
    }

    return self;
}

- (instancetype)initWithObject:(id)anObject {
    if(self = [super init]) {
        _rootNode = [JVBinaryTreeNode nodeWithElement:anObject];
        ++_count;
    }

    return self;
}

- (instancetype)initWithObject:(id)anObject comparator:(NSComparator)comparator {
    if(self = [self initWithObject:anObject]) {
        _comparator = comparator;
    }

    return self;
}

#pragma mark - Adding Objects

- (void)addObjectsFromArray:(NSArray *)array {
    for(id object in array) {
        [self addObject:object];
    }
}

- (void)addObject:(id)anObject {
    if(_rootNode == nil) {
        _rootNode = [JVBinaryTreeNode nodeWithElement:anObject];
        ++_count;
        return;
    }

    if([self addObject:anObject toSubtreeWithParentNode:_rootNode] == YES) ++_count;
}

#pragma mark - Querying the Tree

- (BOOL)containsObject:(id)anObject {
    return [self retrieveNodeWithObject:anObject inSubtreeWithParentNode:_rootNode] == nil ? NO : YES;
}

- (NSComparator)comparator {
    return _comparator;
}

- (NSUInteger)count {
    return _count;
}

- (BOOL)isEmpty {
    return _count == 0 ? YES : NO;
}

- (id)rootObject {
    return _rootNode.element;
}

- (id)maximumObject {
    return [self maximumNodeOfTreeWithRoot:_rootNode].element;
}

- (id)minimumObject {
    return [self minimumNodeOfTreeWithRoot:_rootNode].element;
}

#pragma mark - Removing an Object

- (void)removeMaximumObject {
    id maximum = [self maximumObject];
    [self removeObject:maximum];
}

- (void)removeMinimumObject {
    id minimum = [self minimumObject];
    [self removeObject:minimum];
}

- (void)removeObject:(id)anObject {
    JVBinaryTreeNode *target = [self retrieveNodeWithObject:anObject inSubtreeWithParentNode:_rootNode];
    JVBinaryTreeNode *parent;

    if(target == nil) return;

    parent = [self parentOfNode:target withRoot:_rootNode];
    NSComparisonResult comparisonResult = _comparator(target.element, parent.element);

    if((target.left == nil) && (target.right == nil)) {
        if([target isEqual:_rootNode]) {
            _rootNode = nil;
        } else if((comparisonResult == NSOrderedAscending) || (comparisonResult == NSOrderedSame)) {
            parent.left = nil;
        } else {
            parent.right = nil;
        }
    } else if(target.left == nil) {
        if(comparisonResult == NSOrderedAscending) {
            parent.left = target.right;
        } else {
            parent.right = target.right;
        }

        target.right = nil;
    } else if(target.right == nil) {
        if(comparisonResult == NSOrderedAscending) {
            parent.left = target.left;
        } else {
            parent.right = target.right;
        }

        target.left = nil;
    } else {
        JVBinaryTreeNode *inorderSuccessor = [self inorderSuccessorOfNode:target];
        // NSLog(@"inorderSuccessor of node%lu is node%lu", [target.element integerValue], [inorderSuccessor.element integerValue]);
        target.element = inorderSuccessor.element;
        parent = [self parentOfNode:inorderSuccessor withRoot:target.right];
        // NSLog(@"parent of inorder successor%lu is node%lu", [inorderSuccessor.element integerValue], [parent.element integerValue]);
        parent.left = nil; // we know the inorder successor is on the left
    }

    --_count;
}

- (void)removeObjectsInArray:(NSArray *)array {
    for(id object in array) {
        [self removeObject:object];
    }
}

- (void)removeObjectsInArrayRecursively:(NSArray *)array {
    for(id object in array) {
        [self removeObjectRecursively:object];
    }
}

- (void)removeObjectRecursively:(id)anObject {
    _rootNode = [self removeObjectRecursively:anObject fromSubtreeWithParentNode:_rootNode];
}

#pragma mark - Traversing the Tree

- (NSEnumerator *)enumeratorUsingTraversalOrder:(JVBinarySearchTreeTraversalOrder)order {
    NSEnumerator *enumerator;
    __block JVBinaryTreeNode *currentNode;

    switch(order) {
        case JVBinarySearchTraversalOrderBreadthFirst:
        case JVBinarySearchTraversalOrderLevelOrder: {
            __block JVQueue *queue = [JVQueue queue];
            [queue enqueue:_rootNode];
            enumerator = [[JVBlockEnumerator alloc] initWithBlock:^{
                if(queue.isEmpty) return (id)nil;
                currentNode = [queue dequeue];
                if(currentNode.left != nil) [queue enqueue:currentNode.left];
                if(currentNode.right != nil) [queue enqueue:currentNode.right];
                return currentNode.element;
            }];
        }
        break;
        case JVBinarySearchTraversalOrderPreorder:
        case JVBinarySearchTraversalOrderInOrder:
        case JVBinarySearchTraversalOrderPostOrder: {
            __block NSMutableArray<JVBinaryTreeNode *> *array = [NSMutableArray arrayWithCapacity:_count];
            __block NSUInteger index = 0;
            [self arrangeIntoArray:array withParentNode:_rootNode order:order];
            enumerator = [[JVBlockEnumerator alloc] initWithBlock:^{
                if(index == [array count]) return (id)nil;
                currentNode = [array objectAtIndex:index];
                ++index;
                return currentNode.element;
            }];
        }
        break;
        default:
            [NSException raise:NSInvalidArgumentException format:@"-[%@ %s] %s:%d invalid value for JVBinarySearchTreeTraversalOrder argument", [self class], sel_getName(_cmd), __FILE__, __LINE__];
    }

    return enumerator;
}

#pragma mark - Private methods

- (BOOL)addObject:(nonnull id)anObject toSubtreeWithParentNode:(JVBinaryTreeNode *)parent {
    if(parent == nil) return NO;
    NSComparisonResult comparisonResult = _comparator(anObject, parent.element);
    if((comparisonResult == NSOrderedAscending) || (comparisonResult == NSOrderedSame)) { // add to parent's left subtree
        if(parent.left != nil) return [self addObject:anObject toSubtreeWithParentNode:parent.left];
        else {
            parent.left = [JVBinaryTreeNode nodeWithElement:anObject];
            return YES;
        }
    } else {
        if(parent.right != nil) return [self addObject:anObject toSubtreeWithParentNode:parent.right];
        else {
            parent.right = [JVBinaryTreeNode nodeWithElement:anObject];
            return YES;
        }
    }
}

- (void)arrangeIntoArray:(NSMutableArray<JVBinaryTreeNode *> *)array withParentNode:(JVBinaryTreeNode *)node order:(JVBinarySearchTreeTraversalOrder)order {
    if(node == nil) return;
    switch(order) {
        case JVBinarySearchTraversalOrderBreadthFirst:
        case JVBinarySearchTraversalOrderLevelOrder: {
            NSUInteger index;
            JVQueue *queue = [JVQueue queueWithElement:_rootNode];
            JVBinaryTreeNode *currentNode;
            while(index < _count) {
                currentNode = [queue dequeue];
                if(currentNode.left != nil) [queue enqueue:currentNode.left];
                if(currentNode.right != nil) [queue enqueue:currentNode.right];
                [array addObject:node];
                ++index;
            }
        }
        break;
        case JVBinarySearchTraversalOrderPreorder:
            [array addObject:node];
            [self arrangeIntoArray:array withParentNode:node.left order:order];
            [self arrangeIntoArray:array withParentNode:node.right order:order];
        break;
        case JVBinarySearchTraversalOrderInOrder:
            [self arrangeIntoArray:array withParentNode:node.left order:order];
            [array addObject:node];
            [self arrangeIntoArray:array withParentNode:node.right order:order];
        break;
        case JVBinarySearchTraversalOrderPostOrder:
            [self arrangeIntoArray:array withParentNode:node.left order:order];
            [self arrangeIntoArray:array withParentNode:node.right order:order];
            [array addObject:node];
        break;
        default:
            [NSException raise:NSInvalidArgumentException format:@"-[%@ %s] %s:%d invalid value for JVBinarySearchTreeTraversalOrder argument", [self class], sel_getName(_cmd), __FILE__, __LINE__];
    }
}

- (JVBinaryTreeNode *)inorderSuccessorOfNode:(JVBinaryTreeNode *)node {
    if(node.right == nil) return [self parentOfNode:node withRoot:_rootNode];
    return [self minimumNodeOfTreeWithRoot:node.right];
}

- (JVBinaryTreeNode *)inorderPredecessorOfNode:(JVBinaryTreeNode *)node {
    if(node.left == nil) return [self parentOfNode:node withRoot:_rootNode];
    return [self maximumNodeOfTreeWithRoot:node.left];
}

- (JVBinaryTreeNode *)minimumNodeOfTreeWithRoot:(JVBinaryTreeNode *)root {
    if(root.left == nil) return root;
    return [self minimumNodeOfTreeWithRoot:root.left];
}

- (JVBinaryTreeNode *)maximumNodeOfTreeWithRoot:(JVBinaryTreeNode *)root {
    if(root.right == nil) return root;
    return [self maximumNodeOfTreeWithRoot:root.right];
}

- (JVBinaryTreeNode *)removeObjectRecursively:(id)anObject fromSubtreeWithParentNode:(JVBinaryTreeNode *)parent {
    if(parent == nil) return nil;
    NSComparisonResult comparisonResult = _comparator(anObject, parent.element);
    if(comparisonResult == NSOrderedAscending) {
        parent.left = [self removeObjectRecursively:anObject fromSubtreeWithParentNode:parent.left];
    } else if(comparisonResult == NSOrderedDescending) {
        parent.right = [self removeObjectRecursively:anObject fromSubtreeWithParentNode:parent.right];
    } else if(comparisonResult == NSOrderedSame) {
        if((parent.left == nil) && (parent.right == nil)) {
            parent = nil;
        } else if(parent.left == nil) {
            JVBinaryTreeNode *temp = parent;
            parent = parent.right;
            temp.right = nil;
        } else if(parent.right == nil) {
            JVBinaryTreeNode *temp = parent;
            parent = parent.left;
            temp.left = nil;
        } else {
            JVBinaryTreeNode *inorderPredecessor = [self inorderPredecessorOfNode:parent];
            // NSLog(@"inorderPredecessor of node%lu is node%lu", [parent.element integerValue], [inorderPredecessor.element integerValue]);
            parent.element = inorderPredecessor.element;
            JVBinaryTreeNode *parentOfInorderPredecessor = [self parentOfNode:inorderPredecessor withRoot:parent.left];
            // NSLog(@"parent of inorder predecessor%lu is node%lu", [inorderPredecessor.element integerValue], [parentOfInorderPredecessor.element integerValue]);
            parentOfInorderPredecessor.right = nil;
        }

        --_count;
    }

    return parent;
}

- (JVBinaryTreeNode *)retrieveNodeWithObject:(id)anObject inSubtreeWithParentNode:(JVBinaryTreeNode *)parent {
    if(parent == nil) return nil;
    NSComparisonResult comparisonResult = _comparator(anObject, parent.element);
    if(comparisonResult == NSOrderedSame) {
        return parent;
    } else if(comparisonResult == NSOrderedAscending) {
        return [self retrieveNodeWithObject:anObject inSubtreeWithParentNode:parent.left];
    } else {
        return [self retrieveNodeWithObject:anObject inSubtreeWithParentNode:parent.right];
    }
}

- (JVBinaryTreeNode *)parentOfNode:(JVBinaryTreeNode *)node withRoot:(JVBinaryTreeNode *)root {
    if(root == nil) return nil;
    NSComparisonResult comparisonResult = _comparator(node.element, root.element);
    if((comparisonResult == NSOrderedAscending) || (comparisonResult == NSOrderedSame)) {
        if([node isEqual:root.left]) return root;
        return [self parentOfNode:node withRoot:root.left];
    } else {
        if([node isEqual:root.right]) return root;
        return [self parentOfNode:node withRoot:root.right];
    }
}

@end