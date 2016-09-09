#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import "JVGraphConnectionStore.h"
#import "JVGraphConnectionStoreProtocol.h"

static NSString * const class_JVGraphAALAConnectionStore = @"JVGraphAALAConnectionStore";
static NSString * const class_JVGraphDLAConnectionStore = @"JVGraphDLAConnectionStore";
static NSString * const class_JVGraphAA2LAConnectionStore = @"JVGraphAA2LAConnectionStore";
static NSString * const class_JVGraphD2LAConnectionStore = @"JVGraphD2LAConnectionStore";

@implementation JVGraphConnectionStore {
@private
	id<JVGraphConnectionStoreProtocol> _store;
}

#pragma mark - Creating a Graph Connection Store

#pragma mark - Initializing a Graph Connection Store

- (instancetype)init {
	if(self = [super init]) {
		Class JVGraphD2LAConnectionStore = NSClassFromString(class_JVGraphD2LAConnectionStore);
		_store = [[JVGraphD2LAConnectionStore alloc] init];
	}

	return self;
}

#pragma mark - Adding to a Graph Connection Store

#pragma mark - Removing from a Graph Connection Store

#pragma mark - Querying a Graph Connection Store

@end