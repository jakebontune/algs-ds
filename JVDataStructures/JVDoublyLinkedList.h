#import <Foundation/Foundation.h>
#import "JVDoublyLinkedListEnumerator.h"
#import "../utilities/JVSearchOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface JVDoublyLinkedList<ElementType> : NSObject {
@protected
	NSUInteger _count;
}

@property (readonly) NSUInteger count;
@property (readonly, getter=isEmpty) BOOL empty;
@property (nullable, nonatomic, readonly) ElementType firstObject;
@property (nullable, nonatomic, readonly) ElementType lastObject;
- (instancetype)init;
- (instancetype)initWithObject:(ElementType)anObject;
- (ElementType)objectAtIndex:(NSUInteger)index;
- (JVDoublyLinkedListEnumerator<ElementType> *)objectEnumerator;

@end

@interface JVDoublyLinkedList<ElementType> (JVExtendedSinglyLinkedList)

- (JVDoublyLinkedList<ElementType> *)listByAddingObject:(ElementType)anObject;
- (JVDoublyLinkedList<ElementType> *)listByAddingObjectsFromList:(JVDoublyLinkedList<ElementType> *)otherList;
- (JVDoublyLinkedList<ElementType> *)listByAddingObjectsFromList:(JVDoublyLinkedList<ElementType> *)otherList copy:(BOOL)flag;
- (BOOL)containsObject:(ElementType)anObject;
@property (readonly, copy) NSString *description;
- (NSString *)descriptionWithLocale:(nullable id)locale;
- (NSString *)descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level;
- (nullable ElementType)firstObjectCommonWithList:(JVDoublyLinkedList<ElementType> *)otherList;
- (void)getObjects:(ElementType __weak [])objects range:(NSRange)range;
- (NSUInteger)indexOfObject:(ElementType)anObject;
- (NSUInteger)indexOfObject:(ElementType)anObject inRange:(NSRange)range;
- (NSUInteger)indexOfObjectIdenticalTo:(ElementType)anObject;
- (NSUInteger)indexOfObjectIdenticalTo:(ElementType)anObject inRange:(NSRange)range;
- (BOOL)isEqualToList:(JVDoublyLinkedList<ElementType> *)otherList;
- (JVDoublyLinkedListEnumerator<ElementType> *)reverseObjectEnumerator;
@property (readonly, copy)NSData *sortedListHint;
- (JVDoublyLinkedList<ElementType> *)sortedListUsingFunction:(NSInteger (*)(ElementType, ElementType, void * __nullable))comparator context:(nullable void *)context;
- (JVDoublyLinkedList<ElementType> *)sortedListUsingFunction:(NSInteger (*)(ElementType, ElementType, void * __nullable))comparator context:(nullable void *)context hint:(nullable NSData *)hint;
- (JVDoublyLinkedList<ElementType> *)sortedListUsingSelector:(SEL)comparator;
- (JVDoublyLinkedList<ElementType> *)subListWithRange:(NSRange)range;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically;

- (void)makeObjectsPerformSelector:(SEL)aSelector NS_SWIFT_UNAVAILABLE("Use enumerateObjectsUsingBlock: or a for loop instead");
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(nullable id)argument NS_SWIFT_UNAVAILABLE("Use enumerateObjectsUsingBlock: or a for loop instead");

- (JVDoublyLinkedList<ElementType> *)objectsAtIndexes:(NSIndexSet *)indexes;

- (ElementType)objectAtIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0);

- (void)enumerateObjectsUsingBlock:(void (^)(ElementType obj, NSUInteger idx, BOOL *stop)) block NS_AVAILABLE(10_6, 4_0);
- (void)enumerateObjectsUsingOptions:(NSEnumerationOptions)options usingBlock:(void (^)(ElementType obj, NSUInteger idx, BOOL *stop)) block NS_AVAILABLE(10_6, 4_0);
- (void)enumerateObjectsAtIndexes:(NSIndexSet *)indexes options:(NSEnumerationOptions)options usingBlock:(void (^)(ElementType obj, NSUInteger idx, BOOL *stop)) block NS_AVAILABLE(10_6, 4_0);

- (NSUInteger)indexOfObjectPassingTest:(BOOL (^)(ElementType obj, NSUInteger idx, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);
- (NSUInteger)indexOfObjectWithoptions:(NSEnumerationOptions)options passingTest:(BOOL (^)(ElementType obj, NSUInteger idx, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);
- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)indexes options:(NSEnumerationOptions)options passingTest:(BOOL (^)(ElementType obj, NSUInteger idx, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);

- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (^)(ElementType obj, NSUInteger idx, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);
- (NSIndexSet *)indexesOfObjectsWithoptions:(NSEnumerationOptions)options passingTest:(BOOL (^)(ElementType obj, NSUInteger idx, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);
- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)indexes options:(NSEnumerationOptions)options passingTest:(BOOL (^)(ElementType obj, NSUInteger idx, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0);

- (JVDoublyLinkedList<ElementType> *)sortedListUsingComparator:(NSComparator)comparator NS_AVAILABLE(10_6, 4_0);
- (JVDoublyLinkedList<ElementType> *)sortedListUsingOptions:(NSSortOptions)options usingComparator:(NSComparator)comparator NS_AVAILABLE(10_6, 4_0);

// binary search
- (NSUInteger)indexOfObject:(ElementType)object inSortedRange:(NSRange)range options:(NSBinarySearchingOptions)options usingComparator:(NSComparator)comparator NS_AVAILABLE(10_6, 4_0);

@end

@interface JVDoublyLinkedList<ElementType> (JVDoublyLinkedListCreation)

+ (instancetype)list;
+ (instancetype)listWithObject:(id)anObject;
+ (instancetype)listWithObjects:(const ElementType [])objects count:(NSUInteger)count;
+ (instancetype)listWithObjects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)listWithList:(JVDoublyLinkedList<ElementType> *)list;
+ (instancetype)listWithList:(JVDoublyLinkedList<ElementType> *)list copyItems:(BOOL)flag;
+ (instancetype)listWithArray:(NSArray<ElementType> *)array;
+ (instancetype)listWithArray:(NSArray<ElementType> *)array copyItems:(BOOL)flag;
// TODO: listWith[other collections]

- (instancetype)initWithObjects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithList:(JVDoublyLinkedList<ElementType> *)list;
- (instancetype)initWithList:(JVDoublyLinkedList<ElementType> *)list copyItems:(BOOL)flag;
- (instancetype)initWithArray:(NSArray<ElementType> *)array;
- (instancetype)initWithArray:(NSArray<ElementType> *)array copyItems:(BOOL)flag;
// TODO: initWith[other collections]

+ (nullable JVDoublyLinkedList<ElementType> *)listWithContentsOfFile:(NSString *)path;
+ (nullable JVDoublyLinkedList<ElementType> *)listWithContentsOfURL:(NSURL *)url;
- (nullable JVDoublyLinkedList<ElementType> *)initWithContentsOfFile:(NSString *)path;
- (nullable JVDoublyLinkedList<ElementType> *)initWithContentsOfURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
