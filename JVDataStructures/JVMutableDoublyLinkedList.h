#import "JVDoublyLinkedList.h"

NS_ASSUME_NONNULL_BEGIN

@interface JVMutableDoublyLinkedList<ElementType> : JVDoublyLinkedList<ElementType>

- (void)addObject:(ElementType)anObject;
- (void)insertObject:(ElementType)anObject atIndex:(NSUInteger)index;
- (void)insertObjectAtEnd:(ElementType)anObject;
- (void)removeFirstObject;
- (void)removeLastObject;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(ElementType)anObject;
#pragma mark - TESTING
- (void)print;
- (void)printReverse;
@end

@interface JVMutableDoublyLinkedList<ElementType> (JVExtendedMutableDoublyLinkedList)

- (void)addObjectsFromList:(JVDoublyLinkedList<ElementType> *)otherList;
- (void)addObjectsFromList:(JVDoublyLinkedList<ElementType> *)otherList copyItems:(BOOL)flag;
- (void)addObjectsFromArray:(NSArray<ElementType> *)array;
- (void)addObjectsFromArray:(NSArray<ElementType> *)array copyItems:(BOOL)flag;
// TODO: addObjectsFrom[other collections]
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)removeAllObjects;
- (void)removeObject:(ElementType)anObject inRange:(NSRange)range;
- (void)removeObject:(ElementType)anObject;
- (void)removeObjectIdenticalTo:(ElementType)anObject inRange:(NSRange)range;
- (void)removeObjectIdenticalTo:(ElementType)anObject;
- (void)removeObjectsInList:(JVDoublyLinkedList<ElementType> *)otherList;
- (void)removeObjectsInArray:(NSArray<ElementType> *)array;
// TODO: removeObjectsIn[other collections]
- (void)removeObjectsInRange:(NSRange)range;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromList:(JVDoublyLinkedList<ElementType> *)otherList range:(NSRange)otherRange;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromList:(JVDoublyLinkedList<ElementType> *)otherList;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ElementType> *)array range:(NSRange)otherRange;
- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray<ElementType> *)array;
// TODO: replaceObjectsInRange:withObjectsFrom[other collections]
- (JVDoublyLinkedListEnumerator<ElementType> *)reverseObjectEnumerator;
- (void)setList:(JVDoublyLinkedList<ElementType> *)otherList;
- (void)sortUsingFunction:(NSInteger (*)(ElementType, ElementType, void * __nullable))compare context:(nullable void *)context;
- (void)sortUsingSelector:(SEL)comparator;

- (void)insertObjects:(JVDoublyLinkedList<ElementType> *)objects atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(JVDoublyLinkedList<ElementType> *)objects;

- (void)setObject:(ElementType)object atIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0);

- (void)sortUsingComparator:(NSComparator)comparator NS_AVAILABLE(10_6, 4_0);
- (void)sortWithOptions:(NSSortOptions)options usingComparator:(NSComparator)comparator NS_AVAILABLE(10_6, 4_0);

@end

@interface JVMutableDoublyLinkedList<ElementType> (JVMutableDoublyLinkedListCreation)

+ (instancetype)listWithCapacity:(NSUInteger)numItems;

+ (nullable JVMutableDoublyLinkedList<ElementType> *)listWithContentsOfFile:(NSString *)path;
+ (nullable JVMutableDoublyLinkedList<ElementType> *)listWithContentsOfURL:(NSURL *)url;
- (nullable JVMutableDoublyLinkedList<ElementType> *)initWithContentsOfFile:(NSString *)path;
- (nullable JVMutableDoublyLinkedList<ElementType> *)initWithContentsOfURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END