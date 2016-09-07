#import "JVSinglyLinkedList.h"

NS_ASSUME_NONNULL_BEGIN

@interface JVMutableSinglyLinkedList<ElementType> : JVSinglyLinkedList<ElementType>

- (void)addObject:(ElementType)anObject;
- (void)insertObject:(ElementType)anObject atIndex:(NSUInteger)index;
- (void)insertObjectAtEnd:(ElementType)anObject;
- (void)removeFirstObject;
- (void)removeLastObject;
- (void)removeObject:(ElementType)anObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(ElementType)anObject;
#pragma mark - TESTING
- (void)print;
- (void)printReverse;
@end

@interface JVMutableSinglyLinkedList<ElementType> (JVExtendedMutableSinglyLinkedList)

- (void)addObjectsFromList:(JVSinglyLinkedList<ElementType> *)otherList;
- (void)addObjectsFromList:(JVSinglyLinkedList<ElementType> *)otherList copyItems:(BOOL)flag;
- (void)addObjectsFromArray:(NSArray<ElementType> *)array;
- (void)addObjectsFromArray:(NSArray<ElementType> *)array copyItems:(BOOL)flag;
// TODO: addObjectsFrom[other collections]
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)removeAllObjects;
- (void)removeObject:(ElementType)anObject inRange:(NSRange)range;
- (void)removeObject:(ElementType)anObject;
- (void)removeObjectIdenticalTo:(ElementType)anObject inRange:(NSRange)range;
- (void)removeObjectIdenticalTo:(ElementType)anObject;
- (void)removeObjectsInList:(JVSinglyLinkedList<ElementType> *)otherList;
- (void)removeObjectsInArray:(NSArray<ElementType> *)array;
// TODO: removeObjectsIn[other collections]
- (void)removeObjectsInRange:(NSRange)range;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromList:(JVSinglyLinkedList<ElementType> *)otherList range:(NSRange)otherRange;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromList:(JVSinglyLinkedList<ElementType> *)otherList;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ElementType> *)array range:(NSRange)otherRange;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ElementType> *)array;
// TODO: replaceObjectsInRange:withObjectsFrom[other collections]
- (NSEnumerator<ElementType> *)reverseObjectEnumerator;
- (void)setList:(JVSinglyLinkedList<ElementType> *)otherList;
- (void)sortUsingFunction:(NSInteger (*)(ElementType, ElementType, void * __nullable))compare context:(nullable void *)context;
- (void)sortUsingSelector:(SEL)comparator;

- (void)insertObjects:(JVSinglyLinkedList<ElementType> *)objects atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(JVSinglyLinkedList<ElementType> *)objects;

- (void)setObject:(ElementType)object atIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0);

- (void)sortUsingComparator:(NSComparator)comparator NS_AVAILABLE(10_6, 4_0);
- (void)sortWithOptions:(NSSortOptions)options usingComparator:(NSComparator)comparator NS_AVAILABLE(10_6, 4_0);

@end

@interface JVMutableSinglyLinkedList<ElementType> (JVMutableSinglyLinkedListCreation)

+ (instancetype)listWithCapacity:(NSUInteger)numItems;

+ (nullable JVMutableSinglyLinkedList<ElementType> *)listWithContentsOfFile:(NSString *)path;
+ (nullable JVMutableSinglyLinkedList<ElementType> *)listWithContentsOfURL:(NSURL *)url;
- (nullable JVMutableSinglyLinkedList<ElementType> *)initWithContentsOfFile:(NSString *)path;
- (nullable JVMutableSinglyLinkedList<ElementType> *)initWithContentsOfURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END