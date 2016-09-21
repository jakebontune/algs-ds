#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import <Foundation/Foundation.h>
#import "JVGraphConnectionStoreProtocol.h"
#import "JVGraphConstants.h"
#import "../JVMutableSinglyLinkedList.h"
#import "JVGraphConnectionAttributes.h"
#import "JVGraphDegreeAttributes.h"

/****************************
** JVGraphD2LAConnectionStore
** Dictionary of adjacency Dictionaries of connections Lists of
** connection properties Arrays.
** An adjacency matrix implementation.
** Efficient with graphs with a great amount of vertices and
** connections.
*/
@interface JVGraphD2LAConnectionStore : NSObject<JVGraphConnectionStoreProtocol>

@end

@implementation JVGraphD2LAConnectionStore {
	NSUInteger _directedConnectionCount;
	NSMutableDictionary *_nodeMatrixDictionary;
	NSMutableDictionary *_nodeInfoDictionary;
	NSUInteger _undirectedConnectionCount;
	NSUInteger _uniqueIncidenceCount;
}

#pragma mark - Initializing a Graph D2LA Connection Store

- (instancetype)init {
	if(self = [super init]) {
		_nodeMatrixDictionary = [NSMutableDictionary dictionary];
		_nodeInfoDictionary = [NSMutableDictionary dictionary];
	}

	return self;
}

#pragma mark - Adding to a Graph DLA Connection Store

- (void)setNode:(id)node1
 adjacentToNode:(id)node2
       directed:(BOOL)directed
          value:(NSValue *)value {
    JVMutableSinglyLinkedList *connectionList1, *connectionList2;
    JVGraphConnectionAttributes *connectionAttributes;

    if(directed) {
    	++_directedConnectionCount;
    } else {
    	++_undirectedConnectionCount;
    }

	connectionAttributes = [JVGraphConnectionAttributes attributesWithAdjacentNode:node1 directed:directed initialNode:YES value:value];
}

#pragma mark - Removing from a Graph D2LA Connection Store
#pragma mark - Querying a Graph D2LA Connection Store

@end