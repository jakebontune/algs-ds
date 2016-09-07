#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, JVBinarySearchTreeTraversalOrder) {
    JVBinarySearchTraversalOrderBreadthFirst,
    JVBinarySearchTraversalOrderLevelOrder,
    JVBinarySearchTraversalOrderPreorder,
    JVBinarySearchTraversalOrderInOrder,
    JVBinarySearchTraversalOrderPostOrder
};

// A Binary Search Tree Abstract Data Structure used to arrange data
// in a parent-child recursive tree
@interface JVBinarySearchTree<ObjectType> : NSObject

- (void)addObject:(ObjectType)anObject;
@property(nonatomic) NSComparator comparator;
@property(readonly) NSUInteger count;
- (NSEnumerator<ObjectType> *)enumeratorUsingTraversalOrder:(JVBinarySearchTreeTraversalOrder)order;
@property(readonly, getter=isEmpty) BOOL empty;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithObject:(ObjectType)anObject NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithObject:(ObjectType)anObject comparator:(NSComparator)comparator;
- (void)removeObject:(id)anObject;

@end

@interface JVBinarySearchTree<ObjectType> (JVExtendedBinarySearchTree)

- (void)addObjectsFromArray:(NSArray<ObjectType> *)array;
- (BOOL)containsObject:(ObjectType)anObject;
@property(nullable, nonatomic, readonly) ObjectType maximumObject;
@property(nullable, nonatomic, readonly) ObjectType minimumObject;
- (void)removeMaximumObject;
- (void)removeMinimumObject;
- (void)removeObjectsInArray:(NSArray<ObjectType> *)array;
- (void)removeObjectRecursively:(id)anObject;
- (void)removeObjectsInArrayRecursively:(NSArray<ObjectType> *)array;
@property(nullable, nonatomic, readonly) ObjectType rootObject;

@end

@interface JVBinarySearchTree<ObjectType> (JVBinarySearchTreeCreation)

+ (instancetype)tree;
+ (instancetype)treeWithObject:(ObjectType)anObject;
+ (instancetype)treeWithObject:(ObjectType)anObject comparator:(NSComparator)comparator;

@end

NS_ASSUME_NONNULL_END