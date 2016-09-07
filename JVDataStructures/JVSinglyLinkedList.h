#import <Foundation/Foundation.h>
#import "../utilities/JVSearchOptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface JVSinglyLinkedList<ElementType> : NSObject {
@protected
	NSUInteger _count;
}

@property (readonly) NSUInteger count;
@property (readonly, getter=isEmpty) BOOL empty;
@property (nullable, nonatomic, readonly) ElementType firstObject;
// @property (nullable, nonatomic, readonly) ElementType lastObject;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithObject:(ElementType)anObject;
- (ElementType)objectAtIndex:(NSUInteger)index;
- (NSEnumerator<ElementType> *)objectEnumerator;

@end

@interface JVSinglyLinkedList<ElementType> (JVExtendedSinglyLinkedList)

- (JVSinglyLinkedList<ElementType> *)listByAddingObject:(ElementType)anObject;
- (JVSinglyLinkedList<ElementType> *)listByAddingObjectsFromList:(JVSinglyLinkedList<ElementType> *)otherList;
- (JVSinglyLinkedList<ElementType> *)listByAddingObjectsFromList:(JVSinglyLinkedList<ElementType> *)otherList copy:(BOOL)flag;
- (BOOL)containsObject:(ElementType)anObject;
@property (readonly, copy) NSString *description;
- (NSString *)descriptionWithLocale:(nullable id)locale;
- (NSString *)descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level;
- (nullable ElementType)firstObjectCommonWithList:(JVSinglyLinkedList<ElementType> *)otherList;
- (void)getObjects:(ElementType __weak [])objects range:(NSRange)range;
- (NSUInteger)indexOfObject:(ElementType)anObject inRange:(NSRange)range;
- (NSUInteger)indexOfObjectIdenticalTo:(ElementType)anObject;
- (NSUInteger)indexOfObjectIdenticalTo:(ElementType)anObject inRange:(NSRange)range;
- (BOOL)isEqualToList:(JVSinglyLinkedList<ElementType> *)otherList;
@property (readonly, copy)NSData *sortedListHint;
- (JVSinglyLinkedList<ElementType> *)sortedListUsingFunction:(NSInteger (*)(ElementType, ElementType, void * __nullable))comparator context:(nullable void *)context;
- (JVSinglyLinkedList<ElementType> *)sortedListUsingFunction:(NSInteger (*)(ElementType, ElementType, void * __nullable))comparator context:(nullable void *)context hint:(nullable NSData *)hint;
- (JVSinglyLinkedList<ElementType> *)sortedListUsingSelector:(SEL)comparator;
- (JVSinglyLinkedList<ElementType> *)subListWithRange:(NSRange)range;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically;

- (void)makeObjectsPerformSelector:(SEL)aSelector NS_SWIFT_UNAVAILABLE("Use enumerateObjectsUsingBlock: or a for loop instead");
- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(nullable id)argument NS_SWIFT_UNAVAILABLE("Use enumerateObjectsUsingBlock: or a for loop instead");

- (JVSinglyLinkedList<ElementType> *)objectsAtIndexes:(NSIndexSet *)indexes;

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

- (JVSinglyLinkedList<ElementType> *)sortedListUsingComparator:(NSComparator)comparator NS_AVAILABLE(10_6, 4_0);
- (JVSinglyLinkedList<ElementType> *)sortedListUsingOptions:(NSSortOptions)options usingComparator:(NSComparator)comparator NS_AVAILABLE(10_6, 4_0);

// binary search
- (NSUInteger)indexOfObject:(ElementType)object inSortedRange:(NSRange)range options:(NSBinarySearchingOptions)options usingComparator:(NSComparator)comparator NS_AVAILABLE(10_6, 4_0);

@end

@interface JVSinglyLinkedList<ElementType> (JVSinglyLinkedListCreation)

+ (instancetype)list;
+ (instancetype)listWithObject:(id)anObject;
+ (instancetype)listWithObjects:(const ElementType [])objects count:(NSUInteger)count;
+ (instancetype)listWithObjects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
+ (instancetype)listWithList:(JVSinglyLinkedList<ElementType> *)list;
+ (instancetype)listWithList:(JVSinglyLinkedList<ElementType> *)list copyItems:(BOOL)flag;
+ (instancetype)listWithArray:(NSArray<ElementType> *)array;
+ (instancetype)listWithArray:(NSArray<ElementType> *)array copyItems:(BOOL)flag;
// TODO: listWith[other collections]

- (instancetype)initWithObjects:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;
- (instancetype)initWithList:(JVSinglyLinkedList<ElementType> *)list;
- (instancetype)initWithList:(JVSinglyLinkedList<ElementType> *)list copyItems:(BOOL)flag;
- (instancetype)initWithArray:(NSArray<ElementType> *)array;
- (instancetype)initWithArray:(NSArray<ElementType> *)array copyItems:(BOOL)flag;
// TODO: initWith[other collections]

+ (nullable JVSinglyLinkedList<ElementType> *)listWithContentsOfFile:(NSString *)path;
+ (nullable JVSinglyLinkedList<ElementType> *)listWithContentsOfURL:(NSURL *)url;
- (nullable JVSinglyLinkedList<ElementType> *)initWithContentsOfFile:(NSString *)path;
- (nullable JVSinglyLinkedList<ElementType> *)initWithContentsOfURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
