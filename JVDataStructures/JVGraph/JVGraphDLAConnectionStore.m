#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import <Foundation/Foundation.h>
#import "JVGraphConnectionStoreProtocol.h"

/****************************
** JVGraphDLAConnectionStore
** An adjacency list implementation.
** Dictionary of adjacency Lists of connection properties Arrays.
** Useful for graphs with a great amount of vertices and a small
** amount of connections.
*/
@interface JVGraphDLAConnectionStore : NSObject<JVGraphConnectionStoreProtocol>



@end

@implementation JVGraphDLAConnectionStore {
	NSUInteger _connectionCount;
	NSUInteger _directedConnectionCount;
	NSUInteger _inDegreeCount;
	NSUInteger _undirectedConnectionCount;
	NSUInteger _outDegreeCount;
}

#pragma mark - Creating a Graph DLA Connection Store
#pragma mark - Initializing a Graph DLA Connection Store
#pragma mark - Adding to a Graph DLA Connection Store
#pragma mark - Removing from a Graph DLA Connection Store
#pragma mark - Querying a Graph DLA Connection Store

@end