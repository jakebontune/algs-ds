#import <Foundation/Foundation.h>
#import "JVGraphConnectionStoreProtocol.h"

/****************************
** JVGraphD2LAConnectionStore
** Dictionary of adjacency Dictionaries of connections Lists of
** connection properties Arrays.
** An adjacency matrix implementation.
** Useful for graphs with a great amount of vertices and
** connections.
*/
@interface JVGraphD2LAConnectionStore : NSObject<JVGraphConnectionStoreProtocol>

@end

@implementation JVGraphD2LAConnectionStore {
	NSUInteger _connectionCount;
	NSUInteger _directedConnectionCount;
	NSUInteger _inDegreeCount;
	NSUInteger _undirectedConnectionCount;
	NSUInteger _outDegreeCount;
}

#pragma mark - Creating a Graph D2LA Connection Store
#pragma mark - Initializing a Graph D2LA Connection Store
#pragma mark - Adding to a Graph DLA Connection Store
- (void)addNode:(id)node1
 adjacentToNode:(id)node2
 	   directed:(BOOL)directed
  		  value:(NSValue *)value {
  	NSLog(@"adding from D2LA");
}
#pragma mark - Removing from a Graph D2LA Connection Store
#pragma mark - Querying a Graph D2LA Connection Store

@end