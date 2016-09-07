#import "JVBlockEnumerator.h"

@implementation JVBlockEnumerator {
	id (^_block)(void);
}

#pragma mark - Creating a Block Enumerator

+ (instancetype)enumeratorWithBlock:(id (^)(void))block {
	return [[JVBlockEnumerator alloc] initWithBlock:block];
}

#pragma mark - Initializing a Block Enumerator

- (instancetype)initWithBlock:(id (^)(void))block {
	if(self = [self init]) _block = [block copy];
	return self;
}

#pragma mark - Querying an Enumerator

- (NSArray *)allObjects {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	id object = [self nextObject];
	
	while(object != nil) {
		[array addObject:object];
		object = [self nextObject];
	}

	return array;
}

- (id)nextObject {
	return _block();
}

- (void)setBlock:(id (^)(void))block {
	_block = [block copy];
}

- (id (^)(void))block {
	return _block;
}

@end