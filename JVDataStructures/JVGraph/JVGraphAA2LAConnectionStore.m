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
	NSMutableArray<JVMutableSinglyLinkedList<NSMutableArray *> *> *_adjacencyArray;
	NSMutableArray *_nodeMatrixArray;
	NSUInteger _connectionCount;
	NSMutableArray *_degreeArray;
	NSUInteger _directedConnectionCount;
	NSMutableArray *_inDegreeArray;
	NSMutableArray *_nodeArray;
	NSMutableArray *_outDegreeArray;
	NSUInteger _undirectedConnectionCount;
}

#pragma mark - Creating a Graph AA2LA Connection Store
#pragma mark - Initializing a Graph AA2LA Connection Store
#pragma mark - Adding to a Graph DLA Connection Store
#pragma mark - Removing from a Graph AA2LA Connection Store
#pragma mark - Querying a Graph AA2LA Connection Store

@end