#import "JVMutableDictionary.h"
#import "JVMutableSinglyLinkedList.h"
#import "JVBlockEnumerator.h"

/****************	Dictionary Key-Value Pair	****************/

NS_ASSUME_NONNULL_BEGIN
@interface JVDictionaryKeyValuePair<KeyType, ValueType> : NSObject

@property (nonatomic, copy) KeyType key;
@property (nonatomic, strong) ValueType value;

- (instancetype)initWithKey:(KeyType)key value:(ValueType)value NS_DESIGNATED_INITIALIZER;

+ (instancetype)pair;
+ (instancetype)pairWithKey:(KeyType)key value:(ValueType)value;

@end
NS_ASSUME_NONNULL_END

@implementation JVDictionaryKeyValuePair

#pragma mark - Creating a Key-Value Pair

+ (instancetype)pair {
	return [JVDictionaryKeyValuePair new];
}

+ (instancetype)pairWithKey:(id)key value:(id)value {
	return [[JVDictionaryKeyValuePair alloc] initWithKey:key value:value];
}

#pragma mark - Initializing a Key-Value Pair

- (instancetype)init {
	return [self initWithKey:[NSNull null] value:[NSNull null]];
}

- (instancetype)initWithKey:(id)key value:(id)value {
	if(self = [super init]) {
		self.key = key;
		self.value = value;
	}

	return self;
}

@end

/****************	Fixed Mutable Dictionary	****************/

@interface JVFixedMutableDicitonary : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCapacity:(NSUInteger)capacity NS_DESIGNATED_INITIALIZER;
- (void)setObject:(id)anObject forKey:(id)key;
- (void)removeObjectForKey:(id)key;
- (id)objectForKey:(id)key;
- (NSUInteger)count;
- (NSEnumerator *)keyEnumerator;

@end

@implementation JVFixedMutableDicitonary {
	NSUInteger _count;
	NSUInteger _capacity;
	NSMutableArray<JVMutableSinglyLinkedList *> *_array;
}

#pragma mark - Initializing a Dictionary

- (instancetype)init {
	if(self = [super init]) _array = [NSMutableArray arrayWithCapacity:0];
	return self;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
	if(self = [super init]) {
		_capacity = capacity;
		_array = [[NSMutableArray alloc] initWithCapacity:_capacity];
		for (NSUInteger i = 0; i < _capacity; ++i) {
			[_array insertObject:[JVMutableSinglyLinkedList list] atIndex:i];
		}
	}

	return self;
}

#pragma mark - Adding an Object

- (void)setObject:(id)anObject forKey:(id)key {
	NSUInteger index = [key hash] % _capacity;
	JVMutableSinglyLinkedList<JVDictionaryKeyValuePair *> *list = _array[index];
	JVDictionaryKeyValuePair *pair = nil;

	if(list == nil) {
		pair = [JVDictionaryKeyValuePair pairWithKey:key value:anObject];
		list = [JVMutableSinglyLinkedList listWithObject:pair];
		++_count;
		return;
	}

	NSEnumerator *listEnumerator = [list objectEnumerator];
	pair = [listEnumerator nextObject];
	while(pair != nil) {
		if([[pair key] isEqual:key]) {
			[pair setValue:anObject];
			return;
		}
		pair = [listEnumerator nextObject];
	}

	pair = [JVDictionaryKeyValuePair pairWithKey:key value:anObject];
	[list addObject:pair];
	++_count;
}

#pragma mark - Removing an Object

- (void)removeObjectForKey:(id)key {
	NSUInteger listIndex = [key hash] % _capacity;
	JVMutableSinglyLinkedList *list = _array[listIndex];
	NSUInteger pairIndex = -1;
	NSEnumerator *listEnumerator = [list objectEnumerator];
	JVDictionaryKeyValuePair *pair = nil;

	while(pair = [listEnumerator nextObject]) {
		++pairIndex;
		if([[pair key] isEqual:key]) {
			[list removeObjectAtIndex:pairIndex];
			--_count;
			break;
		}
	}
}

#pragma mark - Querying a Dictionary

- (id)objectForKey:(id)key {
	NSUInteger listIndex = [key hash] % _capacity; // modular hashing
	JVMutableSinglyLinkedList *list = _array[listIndex];
	NSEnumerator *listEnumerator = [list objectEnumerator];
	JVDictionaryKeyValuePair *pair = nil;

	while(pair = [listEnumerator nextObject]) {
		if([[pair key] isEqual:key]) return [pair value];
	}

	return nil;
}

- (NSUInteger)count {
	return _count;
}

#pragma mark - Enumerating a Dictionary

- (NSEnumerator *)keyEnumerator {
	__block NSUInteger index = 0;
	__block JVMutableSinglyLinkedList *list = _array[index];
	__block NSEnumerator *listEnumerator = [list objectEnumerator];
	__block JVDictionaryKeyValuePair *pair = nil;

	// this block itself is just returning the subsequent key whenever it's called.
	// this block is invoked by calling the keyEnumerator's 'nextObject' method
	NSEnumerator *enumerator = [[JVBlockEnumerator alloc] initWithBlock:^{
		while(index < _capacity) {
			while(pair = [listEnumerator nextObject]) {
				return [pair key];
			}
			++index;
			if(index < _capacity) list = _array[index];
			listEnumerator = [list objectEnumerator];
		}

		return (id)nil;
	}];

	return enumerator;
}

@end

/****************	Mutable Dictionary	****************/

@implementation JVMutableDictionary {
	NSUInteger _capacity;
	JVFixedMutableDicitonary *_fixedDicitonary;
}

static const NSUInteger kMaxLoadFactorNumerator = 7;
static const NSUInteger kMaxLoadFactorDenominator = 10;

#pragma mark - Initializing a Dictionary

- (instancetype)init {
	if(self = [super init]){
		_capacity = 4;
		_fixedDicitonary = [[JVFixedMutableDicitonary alloc] initWithCapacity:_capacity];
	}

	return self;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
	capacity = MAX(capacity, 4);
	if(self = [super init]){
		_capacity = capacity;
		_fixedDicitonary = [[JVFixedMutableDicitonary alloc] initWithCapacity:_capacity];
	}

	return self;
}

#pragma mark - Adding Objects

- (void)setObject:(id)anObject forKey:(id)key {
	[_fixedDicitonary setObject:anObject forKey:key];

	// multiply the count:size ratio by yht denominator to get a value
	// greater than zero for comparision
	if(kMaxLoadFactorDenominator * [_fixedDicitonary count] / _capacity > kMaxLoadFactorNumerator) {
		_capacity *= 2;
		JVFixedMutableDicitonary *newDictionary = [[JVFixedMutableDicitonary alloc] initWithCapacity:_capacity];
		NSEnumerator *enumerator = [_fixedDicitonary keyEnumerator];
		for(id k in enumerator) {
			[newDictionary setObject:[_fixedDicitonary objectForKey:k] forKey:k];
		}
		_fixedDicitonary = newDictionary;
	}
}

#pragma mark - Removing Objects

- (void)removeObjectForKey:(id)key {
	[_fixedDicitonary removeObjectForKey:key];
}

#pragma mark - Querying the Dictionary

- (id)objectForKey:(id)key {
	return [_fixedDicitonary objectForKey:key];
}

- (NSUInteger)count {
	return [_fixedDicitonary count];
}

#pragma mark - Enumerating a Dictionary

- (NSEnumerator *)keyEnumerator {
	return [_fixedDicitonary keyEnumerator];
}

@end