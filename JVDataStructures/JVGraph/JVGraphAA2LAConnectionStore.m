#import <Foundation/Foundation.h>
#import "JVGraphConnectionStoreProtocol.h"

/****************************
** JVGraphAA2LAConnectionStore
** Array to store vertices; Array of adjacent Arrays of connections
** Lists of connection properties Arrays.
** An adjacency matrix implementation.
** Useful for graphs with a small amount of vertices and a great
** amount of connections.
*/
@interface JVGraphAA2LAConnectionStore : NSObject<JVGraphConnectionStoreProtocol>



@end

@implementation JVGraphAA2LAConnectionStore {
	NSUInteger _connectionCount;
	NSUInteger _directedConnectionCount;
	NSUInteger _inDegreeCount;
	NSUInteger _undirectedConnectionCount;
	NSUInteger _outDegreeCount;
}

#pragma mark - Creating a Graph AA2LA Connection Store
#pragma mark - Initializing a Graph AA2LA Connection Store
#pragma mark - Adding to a Graph DLA Connection Store
#pragma mark - Removing from a Graph AA2LA Connection Store
#pragma mark - Querying a Graph AA2LA Connection Store

@end