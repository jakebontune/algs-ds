#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import "JVGraphConnectionStore.h"
#import "JVGraphConnectionStoreProtocol.h"

static NSString * const kCLASS_JVGraphAALAConnectionStore = @"JVGraphAALAConnectionStore";
static NSString * const kCLASS_JVGraphDLAConnectionStore = @"JVGraphDLAConnectionStore";
static NSString * const kCLASS_JVGraphAA2LAConnectionStore = @"JVGraphAA2LAConnectionStore";
static NSString * const kCLASS_JVGraphD2LAConnectionStore = @"JVGraphD2LAConnectionStore";

/* Store Representation change thresholds
** Threshold is based on benchmark tests from
** https://www.objc.io/issues/7-foundation/collections/
** Representation is chosen based on following formulas:
** |V| denotes the number of nodes
** |E| denotes the number of connections
** AALA  - |V| < THRESHOLD && |E| < (2/3)|V|^2
** AA2LA - |V| < THRESHOLD && |E| >= (2/3)|V|^2
** DLA 	 - |V| >= THRESHOLD && |E| < (2/3)|V|^2
** D2LA  - |V| >= THRESHOLD && |E| >= (2/3)|V|^2
*/
static NSUInteger const kSTORE_NUM_NODES_THRESHOLD = 500000; // 500,000

@implementation JVGraphConnectionStore {
@private
	id<JVGraphConnectionStoreProtocol> _store;
}

#pragma mark - Creating a Graph Connection Store

#pragma mark - Initializing a Graph Connection Store

- (instancetype)init {
	if(self = [super init]) {
		Class JVGraphAALAConnectionStore = NSClassFromString(kCLASS_JVGraphAALAConnectionStore);
		_store = [[JVGraphAALAConnectionStore alloc] init];
	}

	return self;
}

#pragma mark - Adding to a Graph Connection Store

#pragma mark - Removing from a Graph Connection Store

#pragma mark - Querying a Graph Connection Store

@end