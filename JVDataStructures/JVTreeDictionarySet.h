#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// JVTreeDictionarySet is an structure built around the union-find algorithm.
// It provides O(lg[N]) (less with path compression) methods for
// deducing set relationship between two objects.
// Example uses include finding a path in a graph.
// Unlike other tree set implementations, this structure uses a
// dictionary. This allows for custom indices and constant time
// insertion/deletion (eh...I think).
// This class is graph-default.
@interface JVTreeDictionarySet<KeyType, ObjectType> : NSObject

@property(nonatomic, readonly) NSUInteger count;
- (nullable KeyType)disjoinObjectForKey:(nullable KeyType)key1
		  				  andObjectForKey:(nullable KeyType)key2
							disjoinAtRoot:(BOOL)shouldDisjoinAtRoot
	   				   uprootObjectForKey:(nullable KeyType)keyToUproot;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (void)joinObjectForKey:(nullable KeyType)key1
		 andObjectForKey:(nullable KeyType)key2
		 	   joinRoots:(BOOL)shouldJoinRoots
		disjoinInitially:(BOOL)shouldDisjoinInitially
	  uprootObjectForKey:(nullable KeyType)keyToUproot;
- (NSEnumerator<KeyType> *)keyEnumerator;
- (nullable ObjectType)objectForKey:(nullable KeyType)key;
- (void)removeObjectForKey:(nullable KeyType)key;
- (void)setObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)key;

#pragma mark - TESTING
- (NSUInteger)numberOfDescendantsOfObjectForKey:(KeyType)key;
- (nullable KeyType)parentKeyOfObjectForKey:(nullable KeyType)key;
- (nullable KeyType)rootKeyOfObjectForKey:(nullable KeyType)key;

@end

@interface JVTreeDictionarySet<KeyType, ObjectType> (JVExtendedTreeDictionarySet)

- (void)addEntriesFromDictionary:(NSDictionary<KeyType, ObjectType> *)dictionary;
@property(nonatomic, readonly) NSUInteger averagePathLength;
@property(nonatomic, readonly) NSUInteger componentCount;
- (NSSet<KeyType> *)componentSetContainingObjectForKey:(KeyType)key;
- (nullable KeyType)disjoinObjectForKey:(nullable KeyType)key1 andObjectForKey:(nullable KeyType)key2;
- (NSArray *)disjoinObjectsForKeys:(NSArray<KeyType> *)keysArray1
				 andObjectsForKeys:(NSArray<KeyType> *)keysArray2
				 		 parallely:(BOOL)enumerateParallely;
- (NSArray *)disjoinObjectsForKeys:(NSArray<KeyType> *)keysArray1
				 andObjectsForKeys:(NSArray<KeyType> *)keysArray2
				 		 parallely:(BOOL)enumerateParallely
					 disjoinAtRoot:(BOOL)shouldDisjoinAtRoot
	   				uprootSequence:(nullable NSArray<KeyType> *)uprootSequenceArray;
- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(KeyType key, ObjectType obj, BOOL isComponentRoot, BOOL *stop))block;
- (void)joinObjectForKey:(KeyType)key1 andObjectForKey:(KeyType)key2;
- (void)joinObjectsForKeys:(NSArray<KeyType> *)keysArray1
		andObjectsForKeys:(NSArray<KeyType> *)keysArray2
				parallely:(BOOL)enumerateParallely;
- (void)joinObjectsForKeys:(NSArray<KeyType> *)keysArray1
		 andObjectsForKeys:(NSArray<KeyType> *)keysArray2
		 		 parallely:(BOOL)enumerateParallely
		 	     joinRoots:(BOOL)shouldJoinRoots
		  disjoinInitially:(BOOL)shouldDisjoinInitially
	    	uprootSequence:(nullable NSArray<KeyType> *)uprootSequenceArray;
@property(nonatomic, readonly) NSUInteger longestPathLength;
- (NSEnumerator<ObjectType> *)objectEnumerator;
- (BOOL)objectForKeyIsIsolated:(KeyType)key;
- (BOOL)relationExistsBetweenObjectForKey:(KeyType)key1 andObjectForKey:(KeyType)key2;
- (void)removeAllObjects;
- (void)removeObjectForKey:(id)key preserveComponent:(BOOL)shouldPreserveComponent;
- (void)removeObjectForKey:(id)key preserveWithSuccessor:(BOOL)shouldElectChild;
- (void)removeObjectForKey:(id)key preserveWithPredecessor:(BOOL)shouldElectParent;
- (void)removeObjectsForKeys:(NSArray<KeyType> *)keysArray;
- (void)setObject:(ObjectType)anObject forKey:(KeyType <NSCopying>)key1 andJoinWithObjectForKey:(nullable KeyType)key2;

@end

@interface JVTreeDictionarySet<KeyType, ObjectType> (JVTreeDictionarySetCreation)

- (instancetype)initWithDictionary:(NSDictionary<KeyType, ObjectType> *)dictionary;
+ (instancetype)treeDictionarySet;
+ (instancetype)treeDictionarySetWithDictionary:(NSDictionary<KeyType, ObjectType> *)dictionary;

@end

@interface JVTreeDictionarySet<KeyType, ObjectType> (JVTreeDictionarySetPathCompression)

@property(nonatomic, assign, getter=shouldCompletelyCompressPaths) BOOL completelyCompressPaths;
- (void)compressPathsCompletely;
- (void)compressPathsPartially;
- (void)compressPathsUsingDictionary:(NSDictionary<KeyType, NSArray<KeyType> *> *)dictionary;
@property(nonatomic, assign, getter=shouldPartiallyCompressPaths) BOOL partiallyCompressPaths;

@end

NS_ASSUME_NONNULL_END