#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import "JVTreeDictionarySet.h"
#import "JVBlockEnumerator.h"

static NSString * const kJV_TREE_SET_MEMBER_KEY_OBJECT = @"OBJECT";
static NSString * const kJV_TREE_SET_MEMBER_KEY_PARENT = @"PARENT";
static NSString * const kJV_TREE_SET_MEMBER_KEY_NUM_DESCENDENTS = @"NUM_DESCENDENTS";

// default values
static int const kJV_TREE_SET_ZERO_NUM_CHILDREN = 0;
static int const kJV_TREE_SET_DEFAULT_DICTIONARY_CAPACITY = 3;

// KVO
static NSString * const kJV_TREE_SET_KVO_DICTIONARY_COUNT = @"count";

@implementation JVTreeDictionarySet {
	NSUInteger _averagePathLength;
	BOOL _averagePathLengthShouldUpdate;
	BOOL _completelyCompressPaths;
	NSUInteger _componentCount;
	NSUInteger _longestPathLength;
	BOOL _longestPathLengthShouldUpdate;
	NSMutableDictionary<id <NSCopying>, NSMutableDictionary *> *_mainDictionary;
	BOOL _partiallyCompressPaths;
}

#pragma mark - Creating a Tree Dicitonary Set

+ (instancetype)treeDictionarySet {
	return [[JVTreeDictionarySet alloc] init];
}

+ (instancetype)treeDictionarySetWithObject:(id)anObject forKey:(id)key {
	return [[JVTreeDictionarySet alloc] initWithObject:anObject forKey:key];
}

+ (instancetype)treeDictionarySetWithDictionary:(NSDictionary *)dictionary {
	return [[JVTreeDictionarySet alloc] initWithDictionary:dictionary];
}

#pragma mark - Initializing a Tree Dictionary Set

- (instancetype)init {
	if(self = [super init]) {
		_mainDictionary = [[NSMutableDictionary alloc] init];
		[self registerForKeyValueObserving];
	}

	return self;
}

- (instancetype)initWithObject:(id)anObject forKey:(id)key {
	if(self = [self init]) {
		[self setObject:anObject forKey:key];
	}
	return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	if(self = [self init]) {
		[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			[self setObject:obj forKey:key];
		}];
	}
	return self;
}

#pragma mark - Adding and Joining Objects

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary {
	for(id key in dictionary) {
		[self setObject:dictionary[key] forKey:key];
	}
}

- (void)setObject:(id)anObject forKey:(id)key {
	if(_mainDictionary[key] == nil) {
		NSMutableDictionary *dictionary;
		_mainDictionary[key] = [NSMutableDictionary dictionaryWithCapacity:kJV_TREE_SET_DEFAULT_DICTIONARY_CAPACITY];
		dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
			key, kJV_TREE_SET_MEMBER_KEY_PARENT,
			anObject, kJV_TREE_SET_MEMBER_KEY_OBJECT,
			@(kJV_TREE_SET_ZERO_NUM_CHILDREN), kJV_TREE_SET_MEMBER_KEY_NUM_DESCENDENTS,
			nil
		];
		[_mainDictionary[key] setDictionary:dictionary];
		++_componentCount;
	} else {
		_mainDictionary[key][kJV_TREE_SET_MEMBER_KEY_OBJECT] = anObject;
	}
}

- (void)setObject:(id)anObject forKey:(id)key1 andJoinWithObjectForKey:(id)key2 {
	[self setObject:anObject forKey:key1];
	[self joinObjectForKey:key1 andObjectForKey:key2];
}

- (void)joinObjectForKey:(id)key1 andObjectForKey:(id)key2 {
	if((key1 == nil) || (key2 == nil)) return;
	
	id isolatedKey;
	id abundantKey;

	if([self objectForKeyIsIsolated:key1]) {
		isolatedKey = key1;
		abundantKey = key2;
	} else {
		isolatedKey = key2;
		abundantKey = key1;
	}

	[self joinObjectForKey:isolatedKey
		   andObjectForKey:abundantKey
		   	     joinRoots:NO // this ensures a loner node is appended to an abundant node, not the other way around
		  disjoinInitially:YES
		uprootObjectForKey:nil];
}

// We can choose to join objects by their roots or directly.
- (void)joinObjectForKey:(id)key1
		 andObjectForKey:(id)key2
		 	   joinRoots:(BOOL)shouldJoinRoots
		disjoinInitially:(BOOL)shouldDisjoinInitially
	  uprootObjectForKey:(id)evictedKey {
	if(evictedKey != nil) {
		if(![evictedKey isEqual:key1] && ![evictedKey isEqual:key2])
		; /* TODO: give warning */ // Key to uproot is not one of the keys. Will only cause damage if it is needed.
	}

	id key1RootKey = [self rootKeyOfObjectForKey:key1];
	id key2RootKey = [self rootKeyOfObjectForKey:key2];

	if((key1RootKey == nil) || (key2RootKey == nil) || ([key1 isEqual:key2])) return;

	id undisturbedKey;

	if([key1RootKey isEqual:key2RootKey]) { // in the same component
		// Nothing to do if they are in the same component and we are to join them
		// at their root.

		if(shouldJoinRoots == NO) { // direct join
			if([key1RootKey isEqual:key1]) {
				evictedKey = key2;
				undisturbedKey = key1;
			}else if([key2RootKey isEqual:key2]) {
				evictedKey = key1;
				undisturbedKey = key2;
			}

			if(evictedKey == nil)  { // none are the root
				// TODO: use better metrics for balanced tree

				// Disjoin the node with lesser descendents from its parent and 
				// append to the other.
				if([self numberOfDescendantsOfObjectForKey:key1] <= [self numberOfDescendantsOfObjectForKey:key2]) {
					evictedKey = key1;
					undisturbedKey = key2;
				} else {
					evictedKey = key2;
					undisturbedKey = key1;
				}
			}

			id evictedKeyParentKey = [self parentKeyOfObjectForKey:evictedKey];
			// Check if the undisturbed key is the parent before disjoining and
			// joining to avoid redundancy.
			// If we are in the same component, we will perform direct joining only
			// if we can disjoin one of the nodes prior to joining.
			if(![undisturbedKey isEqual:evictedKeyParentKey] && shouldDisjoinInitially) {
				evictedKey = [self disjoinObjectForKey:evictedKey
					  andObjectForKey:evictedKeyParentKey
					  	disjoinAtRoot:NO
				   uprootObjectForKey:nil];
				if(evictedKey != nil) { // a disjoin took place
					[self setParentKey:undisturbedKey ofObjectForKey:evictedKey];
					[self rootKeyOfObjectForKey:evictedKey updateExaminedNodesWithAmount:([self numberOfDescendantsOfObjectForKey:evictedKey] + 1)];
					--_componentCount;
				}
			}
		}
	} else { // in separate components
		if(shouldJoinRoots) {

			// TODO: use better metrics for balanced tree
			if([self numberOfDescendantsOfObjectForKey:key1RootKey] <= [self numberOfDescendantsOfObjectForKey:key2RootKey]) {
				evictedKey = key1RootKey;
				undisturbedKey = key2RootKey;
			} else {
				evictedKey = key2RootKey;
				undisturbedKey = key1RootKey;
			}
		} else { // If we should not join at root and they are in separate
				 // components the default is to either find the one that is a root
				 // or dislodge one of them according to the expected evictedKey
				 // and shouldDisjoinInitially parameters
			if([key1RootKey isEqual:key1] && ![key2RootKey isEqual:key2]) {
				evictedKey = key2;
				undisturbedKey = key1;
			} else if([key2RootKey isEqual:key2] && ![key1RootKey isEqual:key1]) {
				evictedKey = key1;
				undisturbedKey = key2;
			} else if([key1RootKey isEqual:key1] && [key2RootKey isEqual:key2]) {

				// TODO: use better metrics for balanced tree
				if([self numberOfDescendantsOfObjectForKey:key1] <= [self numberOfDescendantsOfObjectForKey:key2]) {
					evictedKey = key1;
					undisturbedKey = key2;
				} else {
					evictedKey = key2;
					undisturbedKey = key1;
				}
			} else { // both are not roots
				// We can join two nodes in separate components only if we can
				// disjoin initially and a key to uproot is specified.
				if(shouldDisjoinInitially) {
					NSAssert(evictedKey != nil, @"Joining a pair of non-root nodes in separate components requires that the key to uproot not be nil.");
					if(![evictedKey isEqual:key1] && ![evictedKey isEqual:key2]) return; /* TODO: give warning */ // Key to uproot is not one of the keys. Disastrous situation!
					if([evictedKey isEqual:key1]) {
						undisturbedKey = key2;
					} else {
						undisturbedKey = key1;
					}

					evictedKey = [self disjoinObjectForKey:evictedKey
							  				andObjectForKey:[self parentKeyOfObjectForKey:evictedKey]
											  disjoinAtRoot:NO
						   				 uprootObjectForKey:nil];
				} else {
					// cannot join nodes in separate components unless explicitly
					// instructed to join at the root or disjoin initially with
					// a key to uproot specified.
					/* TODO: give warning */
					return;
				}
			}
		}

		[self setParentKey:undisturbedKey ofObjectForKey:evictedKey];
		[self rootKeyOfObjectForKey:evictedKey updateExaminedNodesWithAmount:([self numberOfDescendantsOfObjectForKey:evictedKey] + 1)];
		--_componentCount;
	}
}

- (void)joinObjectsForKeys:(NSArray *)keysArray1
		andObjectsForKeys:(NSArray *)keysArray2
				parallely:(BOOL)enumerateParallely {
	[self joinObjectsForKeys:keysArray1
		   andObjectsForKeys:keysArray2
				   parallely:enumerateParallely
				   joinRoots:YES
			disjoinInitially:NO
			  uprootSequence:nil];
}

- (void)joinObjectsForKeys:(NSArray *)keysArray1
		 andObjectsForKeys:(NSArray *)keysArray2
		 		 parallely:(BOOL)enumerateParallely
		 	     joinRoots:(BOOL)shouldJoinRoots
		  disjoinInitially:(BOOL)shouldDisjoinInitially
	    	uprootSequence:(NSArray *)uprootSequenceArray {
	NSEnumerator *key1Enumerator = [keysArray1 objectEnumerator], *key2Enumerator, *uprootEnumerator;
	id key1;

	if(enumerateParallely) {
		NSAssert(keysArray1.count == keysArray2.count, @"Parallel join requires that the sizes of the key arrays to join should match.");
		if(uprootSequenceArray != nil) {
			NSAssert(uprootSequenceArray.count == keysArray1.count, @"Parallel join requires that the uproot sequence array have the same size as the keys arrays");
			uprootEnumerator = [uprootSequenceArray objectEnumerator];
		}

		key2Enumerator = [keysArray2 objectEnumerator];
		while((key1 = [key1Enumerator nextObject]) != nil) {
			[self joinObjectForKey:key1
				   andObjectForKey:[key2Enumerator nextObject]
					     joinRoots:shouldJoinRoots
				  disjoinInitially:shouldDisjoinInitially
				uprootObjectForKey:[uprootEnumerator nextObject]];
		}
	} else {
		id key2;
		while((key1 = [key1Enumerator nextObject]) != nil) {
			if(uprootSequenceArray != nil) uprootEnumerator = [uprootSequenceArray objectEnumerator];
			key2Enumerator = [keysArray2 objectEnumerator];
			while((key2 = [key2Enumerator nextObject]) != nil) {
				[self joinObjectForKey:key1
				   andObjectForKey:key2
					     joinRoots:shouldJoinRoots
				  disjoinInitially:shouldDisjoinInitially
				uprootObjectForKey:[uprootEnumerator nextObject]];
			}
		}
	}
}

#pragma mark - Removing and Disjoining Objects

- (void)removeAllObjects {
	for(id key in _mainDictionary) {
		[self removeObjectForKey:key];
	}
}

- (void)removeObjectForKey:(id)key {
	[self removeObjectForKey:key
		   preserveComponent:NO
	   preserveWithSuccessor:NO
	 preserveWithPredecessor:NO];
}

- (void)removeObjectForKey:(id)key preserveComponent:(BOOL)shouldPreserveComponent {
	[self removeObjectForKey:key
		   preserveComponent:YES
	   preserveWithSuccessor:YES
	 preserveWithPredecessor:YES];
}

- (void)removeObjectForKey:(id)key preserveWithSuccessor:(BOOL)shouldElectChild {
	[self removeObjectForKey:key
		   preserveComponent:YES
	   preserveWithSuccessor:YES
	 preserveWithPredecessor:NO];
}

- (void)removeObjectForKey:(id)key preserveWithPredecessor:(BOOL)shouldElectParent {
	[self removeObjectForKey:key
		   preserveComponent:YES
	   preserveWithSuccessor:NO
	 preserveWithPredecessor:YES];
}

- (void)removeObjectsForKeys:(NSArray *)keysArray {
	for(id key in keysArray) {
		[self removeObjectForKey:key];
	}
}

- (id)disjoinObjectForKey:(id)key1 andObjectForKey:(id)key2 {
	return [self disjoinObjectForKey:key1
					 andObjectForKey:key2
					   disjoinAtRoot:NO
				  uprootObjectForKey:nil];
}

// Returning nil signifies that no disjoining took place
- (id)disjoinObjectForKey:(id)key1
		  andObjectForKey:(id)key2
			disjoinAtRoot:(BOOL)shouldDisjoinAtRoot
	   uprootObjectForKey:(id)evictedKey {
	if(evictedKey != nil) {
		if(![evictedKey isEqual:key1] && ![evictedKey isEqual:key2])
		; /* TODO: give warning */ // The key to uproot is not one of the keys. Only sever if it is needed.
	}

	if([key1 isEqual:key2]) return nil;

	id key1RootKey = [self rootKeyOfObjectForKey:key1];
	id key2RootKey = [self rootKeyOfObjectForKey:key2];

	if((key1RootKey == nil) || (key2RootKey == nil)) return nil; // no objects associated with the keys specified

	if(![key1RootKey isEqual:key2RootKey]) return nil; // keys are in different components

	id higherKey, lowerKey, rootKey;
	BOOL key1IsLower, key2IsLower;

	key1IsLower = [self pathToRootContainsObjectForKey:key2 startFromObjectForKey:key1];
	key2IsLower = [self pathToRootContainsObjectForKey:key1 startFromObjectForKey:key2];

	if(key1IsLower || key2IsLower) { // on same path
		if(key1IsLower) {
			lowerKey = key1;
			higherKey = key2;
		} else {
			lowerKey = key2;
			higherKey = key1;
		}

		rootKey = lowerKey;

		// If we're disjoining at root, we need to get the node directly below the
		// higher key
		if(shouldDisjoinAtRoot) {
			id rootKeyParentKey = [self parentKeyOfObjectForKey:rootKey];
			while(![rootKeyParentKey isEqual:higherKey]) {
				rootKey = rootKeyParentKey;
				rootKeyParentKey = [self parentKeyOfObjectForKey:rootKey];
			}
		}
	} else { // on separate paths
		// If the nodes are on separate paths and we are not disjoining at the root,
		// there is no disjoining to perform
		if(shouldDisjoinAtRoot == NO) return nil;

		// We can disjoin nodes on separate paths only if explicitly instructed to
		// disjoin at root and a key to uproot is stated. 
		NSAssert(evictedKey != nil, @"Disjoining at root requires that the uproot key not be nil"); // Only useful if keys are on separate paths
		if(![evictedKey isEqual:key1] && ![evictedKey isEqual:key2]) /* TODO: give warning */ return nil; // The key to uproot is not one of the keys. Disastrous situation!

		// Disjoining the uproot key at the root requires us to get a hold of the
		// key directly below the root on the uproot's path and uproot that
		rootKey = evictedKey;
		id evictedKeyRootKey = [self rootKeyOfObjectForKey:rootKey];
		id rootKeyParentKey = [self parentKeyOfObjectForKey:rootKey];
		while(![rootKeyParentKey isEqual:evictedKeyRootKey]) {
			rootKey = rootKeyParentKey;
			rootKeyParentKey = [self parentKeyOfObjectForKey:rootKey];
		}
	}

	// update the number of descendents of the uproot key's ancestors before disjoining
	[self rootKeyOfObjectForKey:rootKey updateExaminedNodesWithAmount:-([self numberOfDescendantsOfObjectForKey:rootKey] + 1)];
	// set it free
	[self setParentKey:rootKey ofObjectForKey:rootKey];

	++_componentCount;

	return rootKey;
}

- (NSArray *)disjoinObjectsForKeys:(NSArray *)keysArray1
				 andObjectsForKeys:(NSArray *)keysArray2
				 		 parallely:(BOOL)enumerateParallely {
	return [self disjoinObjectsForKeys:keysArray1
					 andObjectsForKeys:keysArray2
					 		 parallely:enumerateParallely
						 disjoinAtRoot:NO
						uprootSequence:nil];
}

- (NSArray *)disjoinObjectsForKeys:(NSArray *)keysArray1
				 andObjectsForKeys:(NSArray *)keysArray2
				 		 parallely:(BOOL)enumerateParallely
					 disjoinAtRoot:(BOOL)shouldDisjoinAtRoot
	   				uprootSequence:(NSArray *)uprootSequenceArray {
	NSEnumerator *key1Enumerator = [keysArray1 objectEnumerator], *key2Enumerator, *uprootEnumerator;
	id key1, disjoinResult;
	NSMutableArray *array = [NSMutableArray array];

	if(enumerateParallely) {
		NSAssert(keysArray1.count == keysArray2.count, @"Parallel disjoin requires that the sizes of the key arrays to disjoin should match.");
		if(uprootSequenceArray != nil) {
			NSAssert(uprootSequenceArray.count == keysArray1.count, @"Parallel disjoin requires that the uproot sequence array have the same size as the keys arrays");
			uprootEnumerator = [uprootSequenceArray objectEnumerator];
		}

		key2Enumerator = [keysArray2 objectEnumerator];
		while((key1 = [key1Enumerator nextObject]) != nil) {
			disjoinResult = [self disjoinObjectForKey:key1
					  				  andObjectForKey:[key2Enumerator nextObject]
					    				disjoinAtRoot:shouldDisjoinAtRoot
					   			   uprootObjectForKey:[uprootEnumerator nextObject]];
			if(disjoinResult == nil) disjoinResult = [NSNull null];
			[array addObject:disjoinResult];
		}
	} else {
		id key2;
		while((key1 = [key1Enumerator nextObject]) != nil) {
			if(uprootSequenceArray != nil) uprootEnumerator = [uprootSequenceArray objectEnumerator];
			key2Enumerator = [keysArray2 objectEnumerator];
			while((key2 = [key2Enumerator nextObject]) != nil) {
				disjoinResult = [self disjoinObjectForKey:key1
										  andObjectForKey:key2
											disjoinAtRoot:shouldDisjoinAtRoot
						   			   uprootObjectForKey:[uprootEnumerator nextObject]];
				if(disjoinResult == nil) disjoinResult = [NSNull null];
				[array addObject:disjoinResult];
			}
		}
	}

	return [NSArray arrayWithArray:array];
}

#pragma mark - Querying a Tree Set

- (NSUInteger)averagePathLength {
	if(_averagePathLengthShouldUpdate) {
		NSUInteger *pathLength;
		NSUInteger totalPathLength;
		NSUInteger leavesCount;
		for(id key in _mainDictionary) {
			if([self numberOfDescendantsOfObjectForKey:key] == 0) {
				[self rootKeyOfObjectForKey:key pathLength:pathLength];
				totalPathLength += *pathLength;
				++leavesCount;
			}
		}

		_averagePathLength = (totalPathLength / leavesCount);
		_averagePathLengthShouldUpdate = NO;
	}

	return _averagePathLength;
}

- (NSUInteger)componentCount {
	return _componentCount;
}

- (NSSet *)componentSetContainingObjectForKey:(id)key {
	id rootKey = [self rootKeyOfObjectForKey:key];
	if(rootKey == nil) return [NSSet set];
	NSMutableSet *set = [NSMutableSet set];
	for(id aKey in _mainDictionary) {
		if([[self rootKeyOfObjectForKey:aKey] isEqual:rootKey]) [set addObject:aKey];
	}

	return [NSSet setWithSet:set];
}

- (NSUInteger)count {
	return [_mainDictionary count];
}

- (NSUInteger)longestPathLength {
	if(_longestPathLengthShouldUpdate) {
		NSUInteger oldPathLength;
		NSUInteger *pathLength;
		for(id key in _mainDictionary) {
			if([self numberOfDescendantsOfObjectForKey:key] == 0) {
				oldPathLength = *pathLength;
				[self rootKeyOfObjectForKey:key pathLength:pathLength];
				_longestPathLength = MAX(oldPathLength, *pathLength);
			}
		}

		_longestPathLengthShouldUpdate = NO;
	}

	return _longestPathLength;
}

- (id)objectForKey:(id)key {
	return _mainDictionary[key][kJV_TREE_SET_MEMBER_KEY_OBJECT];
}

- (BOOL)objectForKeyIsIsolated:(id)key {
	// NSAssert(_mainDictionary[key] != nil, @"No object for key %@ found in set.", [key description]);
	if(([self numberOfDescendantsOfObjectForKey:key] == kJV_TREE_SET_ZERO_NUM_CHILDREN) && [self objectForKeyIsComponentRoot:key]) {
		return YES;
	}

	return NO;
}

- (BOOL)relationExistsBetweenObjectForKey:(id)key1 andObjectForKey:(id)key2 {
	id key1RootKey = [self rootKeyOfObjectForKey:key1];
	id key2RootKey = [self rootKeyOfObjectForKey:key2];

	// NSAssert((key1RootKey != nil) && (key2RootKey != nil), @"Keys must be non-nil to deduce relationship.");
	
	if([key1RootKey isEqual:key2RootKey]) return YES;

	return NO;
}

- (void)setCompletelyCompressPaths:(BOOL)flag {
	_completelyCompressPaths = flag;
}

- (void)setPartiallyCompressPaths:(BOOL)flag {
	_partiallyCompressPaths = flag;
}

- (BOOL)shouldCompletelyCompressPaths {
	return _completelyCompressPaths;
}

- (BOOL)shouldPartiallyCompressPaths {
	return _partiallyCompressPaths;
}

#pragma mark - Compressing Paths

- (void)compressPathsPartially {
	NSMutableArray *keysArray = [NSMutableArray array];

	// We gather all non-isolated nodes first to avoid altering the main
	// dictionary while enumerating through it.
	for(id key in _mainDictionary) {
		if(![self objectForKeyIsIsolated:key] && ([self numberOfDescendantsOfObjectForKey:key] == kJV_TREE_SET_ZERO_NUM_CHILDREN)) {
			[keysArray addObject:key];
		}
	}

	for(id key in keysArray) {
		[self compressPathsPartiallyWithKey:key];
	}
}

- (void)compressPathsCompletely {
	NSMutableArray *keysArray = [NSMutableArray array];

	// We gather all non-isolated nodes first to avoid altering the main
	// dictionary while enumerating through it.
	for(id key in _mainDictionary) {
		if(![self objectForKeyIsIsolated:key] && ([self numberOfDescendantsOfObjectForKey:key] == kJV_TREE_SET_ZERO_NUM_CHILDREN)) {
			[keysArray addObject:key];
		}
	}

	for(id key in keysArray) {
		[self compressPathsCompletelyWithKey:key];
	}
}

// Join a key with the upward shortest path-ed key in its associated array
// TODO: use better metrics
- (void)compressPathsUsingDictionary:(NSDictionary *)dictionary {
	__block id potentialParentKey, rootKey, arrayKeyRootKey;
	__block NSUInteger *keyPathLength, *arrayKeyPathLength, *potentialParentPathLength;

	[dictionary enumerateKeysAndObjectsUsingBlock:^(id key, NSArray *keysArray, BOOL *stop) {
		rootKey = [self rootKeyOfObjectForKey:key pathLength:keyPathLength];
		if([rootKey isEqual:key]) return; // key is its root
		for(id arrayKey in keysArray) {
			if(_mainDictionary[arrayKey] == nil) /* TODO: give warning */ continue; // key in array is not a member
			if([arrayKey isEqual:key]) continue; // the keys are the same
			*potentialParentPathLength = *arrayKeyPathLength;
			arrayKeyRootKey = [self rootKeyOfObjectForKey:arrayKey pathLength:arrayKeyPathLength];
			if(![rootKey isEqual:arrayKeyRootKey]) /*TODO: give warning */ continue; // In separate components
			if(([arrayKey isEqual:arrayKeyRootKey]) && (![[self parentKeyOfObjectForKey:key] isEqual:arrayKey])) {
				[self disjoinObjectForKey:key andObjectForKey:[self parentKeyOfObjectForKey:key]];
				[self joinObjectForKey:key andObjectForKey:arrayKey];
				break;
			}

			if(*arrayKeyPathLength <= *potentialParentPathLength) {
				potentialParentKey = arrayKey;
				*potentialParentPathLength = *arrayKeyPathLength;
			}
		}

		if(potentialParentKey != nil) {
			if((*keyPathLength < *potentialParentPathLength) && (![[self parentKeyOfObjectForKey:key] isEqual
				:potentialParentKey])) {
				[self disjoinObjectForKey:key andObjectForKey:[self parentKeyOfObjectForKey:key]];
				[self joinObjectForKey:key andObjectForKey:potentialParentKey];
			}
		}
	}];
}

#pragma mark - Enumerating a Tree Dictionary Set

- (NSEnumerator *)keyEnumerator {
	return [_mainDictionary keyEnumerator];
}

- (NSEnumerator *)objectEnumerator {
	__block NSEnumerator *keyEnumerator = [_mainDictionary keyEnumerator];
	NSEnumerator *enumerator = [JVBlockEnumerator enumeratorWithBlock:^{
		return [self objectForKey:[keyEnumerator nextObject]];
	}];

	return enumerator;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL isComponentRoot, BOOL *stop))block {
	BOOL stop = NO, isComponentRoot = NO;
	id key, obj;
	NSEnumerator *keyEnumerator = [_mainDictionary keyEnumerator];

	while((stop == NO) && (key = [keyEnumerator nextObject]) != nil) {
		obj = [self objectForKey:key];
		if([self objectForKeyIsComponentRoot:key]) {
			isComponentRoot = YES;
		} else {
			isComponentRoot = NO;
		}

		block(key, obj, isComponentRoot, &stop);
	}
}

#pragma mark - Private Methods

- (void)compressPathsCompletelyWithKey:(id)key {
	id rootKey = [self rootKeyOfObjectForKey:key];

	if(rootKey == nil) return;

	id 	parentKey = [self parentKeyOfObjectForKey:key];
	NSUInteger missingChildren;

	// Set the parent of all the nodes we passed by to the
	// root. Up to the direct child of the root,
	// the number of descendents to remove from subsequent
	// nodes increases by one each step.
	while(![key isEqual:parentKey]) {
		[self setNumberOfDescendants:[self numberOfDescendantsOfObjectForKey:key] + missingChildren ofObjectForKey:key];
		++missingChildren;
		[self setParentKey:rootKey ofObjectForKey:key];
		key = parentKey;
		parentKey = [self parentKeyOfObjectForKey:parentKey];
	}
	// No need to update root's number of descendents as it remains the
	// topmost ancestor
}

- (void)compressPathsPartiallyWithKey:(id)key {
	id rootKey =[self rootKeyOfObjectForKey:key];

	if(rootKey == nil) return;

	id parentKey = [self parentKeyOfObjectForKey:key];
	id grandParentKey = [self parentKeyOfObjectForKey:parentKey];

	// Set the parent of all nodes we passed to it's grandparent.
	// As we go up to the direct child of the root, we subtract
	// from the parents (excluding the root) of subsequent nodes,
	// the number of descendents of the current node plus one (itself).
	while(![parentKey isEqual:rootKey]) {
		[self setNumberOfDescendants:-([self numberOfDescendantsOfObjectForKey:key] + 1) ofObjectForKey:parentKey];
		[self setParentKey:grandParentKey ofObjectForKey:key];
		key = parentKey;
		parentKey = grandParentKey;
		grandParentKey = [self parentKeyOfObjectForKey:parentKey];
	}
}

- (BOOL)objectForKeyIsComponentRoot:(id)key {
	// NSAssert(_mainDictionary[key] != nil, @"No object for key:%@ found in set.", [key description]);
	return [[self parentKeyOfObjectForKey:key] isEqual:key];
}

// Determine whether the search key lives on the path going up from the start key to the start key's root
- (BOOL)pathToRootContainsObjectForKey:(id)searchKey startFromObjectForKey:(id)startKey {
	NSAssert(_mainDictionary[startKey] != nil, @"Start object for key %@ is not a member", [startKey description]);
	if((_mainDictionary[startKey] == nil) || (_mainDictionary[searchKey] == nil)) return NO;

	id startKeyParentKey = [self parentKeyOfObjectForKey:startKey];
	while(![startKey isEqual:startKeyParentKey]) {
		if([startKey isEqual:searchKey]) return YES;
		startKey = startKeyParentKey;
		startKeyParentKey = [self parentKeyOfObjectForKey:startKey];
	}

	if([startKey isEqual:searchKey]) return YES;

	return NO;
}

- (void)removeObjectForKey:(id)key
		 preserveComponent:(BOOL)shouldPreserveComponent
	 preserveWithSuccessor:(BOOL)shouldElectChild
   preserveWithPredecessor:(BOOL)shouldElectParent {
	if(_mainDictionary[key] == nil) return;

	id heir, parentKey;
	NSMutableArray *keysArray;
	BOOL foundPredecessor;

	if([self objectForKeyIsIsolated:key]) {
		--_componentCount;
	} else {
		for(id childKey in _mainDictionary) {
			parentKey = [self parentKeyOfObjectForKey:childKey];
			if(![childKey isEqual:key] && [parentKey isEqual:key]) {
				[keysArray addObject:childKey];
			}
		}

		if(shouldPreserveComponent) {
			if(shouldElectParent) {
				parentKey = [self parentKeyOfObjectForKey:key];
				if([key isEqual:parentKey] && !shouldElectChild) { // no predecessor and no heir should be chosen
					for(id childKey in keysArray) {
						// children must become independent
						[self setParentKey:childKey ofObjectForKey:childKey];
						++_componentCount;
					}
				} else if(![key isEqual:parentKey]) { // has predecessor
					for(id childKey in keysArray) {
						[self setParentKey:parentKey ofObjectForKey:childKey];
					}
					// inform elders of departure
					[self rootKeyOfObjectForKey:key updateExaminedNodesWithAmount:-1];
					foundPredecessor = YES;
				}
			}

			if(shouldElectChild && !foundPredecessor) { // find an heir
				if(!([keysArray count] == kJV_TREE_SET_ZERO_NUM_CHILDREN)) { // has children
					heir = [keysArray firstObject];
					[self setNumberOfDescendants:([self numberOfDescendantsOfObjectForKey:key] - 1) ofObjectForKey:heir]; // inherit leaving node's children minus itself
					for(NSUInteger i = 1; i < [keysArray count]; ++i) {
						// siblings now refer to heir as family head
						[self setParentKey:heir ofObjectForKey:[keysArray objectAtIndex:i]];
					}
					parentKey = [self parentKeyOfObjectForKey:key];
					if([key isEqual:parentKey]) { // no grandparent so it is now root
						[self setParentKey:heir ofObjectForKey:heir];
					} else {
						// has grandparent so it stems from it and elders must be informed of departure
						[self setParentKey:parentKey ofObjectForKey:heir];
						[self rootKeyOfObjectForKey:key updateExaminedNodesWithAmount:-1];
					}
				}
			}
		} else { // do not preserve family structure
			for(id childKey in keysArray) {
				// children must become independent
				[self setParentKey:childKey ofObjectForKey:childKey];
				++_componentCount;
			}
			// inform elders of its departure and that of its children
			[self rootKeyOfObjectForKey:key updateExaminedNodesWithAmount:-([self numberOfDescendantsOfObjectForKey:key] + 1)];
		}
	}

	[_mainDictionary removeObjectForKey:key];
}

- (id)rootKeyOfObjectForKey:(id)key {
	return [self rootKeyOfObjectForKey:key updateExaminedNodesWithAmount:0 pathLength:NULL];
}

- (id)rootKeyOfObjectForKey:(id)key pathLength:(NSUInteger *)pathLength {
	return [self rootKeyOfObjectForKey:key updateExaminedNodesWithAmount:0 pathLength:pathLength];
}

- (id)rootKeyOfObjectForKey:(id)key updateExaminedNodesWithAmount:(NSUInteger)amount {
	return [self rootKeyOfObjectForKey:key updateExaminedNodesWithAmount:amount pathLength:NULL];
}

// Get the root key of a key and increase the the number of descendents
// of all nodes we pass on the way (not including the start key)
// by a specified number.
// Keep track of the length of the upward path
- (id)rootKeyOfObjectForKey:(id)key updateExaminedNodesWithAmount:(NSUInteger)amount pathLength:(NSUInteger *)pathLength {
	id rootKey = key;
	NSUInteger pLength;
	id parentKey = [self parentKeyOfObjectForKey:rootKey];

	if(parentKey == nil) return nil;

	if(_completelyCompressPaths) {
		[self compressPathsCompletelyWithKey:key];
	} else if(_partiallyCompressPaths) {
		[self compressPathsPartiallyWithKey:key];
	}

	// move to top most ancestor of given key
	while(![rootKey isEqual:parentKey]) {
		rootKey = parentKey;
		[self setNumberOfDescendants:([self numberOfDescendantsOfObjectForKey:parentKey] + amount) ofObjectForKey:parentKey];
		++pLength;
	}

	if(pathLength != NULL) *pathLength = pLength;

	return rootKey;
}

#pragma mark - Private Node Properties Accessor Methods

- (NSUInteger)numberOfDescendantsOfObjectForKey:(id)key {
	NSDictionary *dictionary = _mainDictionary[key];
	// NSAssert(dictionary != nil, @"No found object for key %@", [key description]);
	return ((NSNumber *)dictionary[kJV_TREE_SET_MEMBER_KEY_NUM_DESCENDENTS]).integerValue;
}

- (id)parentKeyOfObjectForKey:(id)key {
	return _mainDictionary[key][kJV_TREE_SET_MEMBER_KEY_PARENT];
}

- (void)setNumberOfDescendants:(NSUInteger)numDescendents ofObjectForKey:(id)key {
	_mainDictionary[key][kJV_TREE_SET_MEMBER_KEY_NUM_DESCENDENTS] = @(numDescendents);
}

- (void)setParentKey:(nonnull id)parentKey ofObjectForKey:(id)key {
	_mainDictionary[key][kJV_TREE_SET_MEMBER_KEY_PARENT] = parentKey;
}

#pragma mark - Key-Value Observing

- (void)registerForKeyValueObserving {
	[_mainDictionary addObserver:self
					  forKeyPath:kJV_TREE_SET_KVO_DICTIONARY_COUNT
						 options:NSKeyValueObservingOptionNew
						 context:NULL];
}

- (void)unregisterForKeyValueObserving {
	[_mainDictionary removeObserver:self
						 forKeyPath:kJV_TREE_SET_KVO_DICTIONARY_COUNT];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
					    change:(NSDictionary *)change
					   context:(void *)context {
	if([keyPath isEqual:kJV_TREE_SET_KVO_DICTIONARY_COUNT]) {
		_averagePathLengthShouldUpdate = YES;
		_longestPathLengthShouldUpdate = YES;
	}
}

@end