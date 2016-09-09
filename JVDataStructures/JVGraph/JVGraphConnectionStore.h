#import <Foundation/Foundation.h>

// The Graph Connection Store has the task of keeping track of
// adjacency metrics in various forms and is able convert between
// these forms when appropriate (in the context of time-space
// efficiency).

@interface JVGraphConnectionStore<NodeType> : NSObject

typedef NS_OPTIONS(NSUInteger, JVGraphConnectionOrientationOptions) {
    JVGraphConnectionOrientationDirected = 5 << 0, // 0000 0101
    JVGraphConnectionOrientationUndirected = 5 << 1, // 0000 1010
};

typedef NS_OPTIONS(NSUInteger, JVGraphVertexOrientationOptions) {
    JVGraphVertexOrientationInitial = 3 << 0, // 0000 0011
    JVGraphVertexOrientationTerminal = 3 << 2, // 0000 1100
};

- (void)addNode:(NodeType)node1
 adjacentToNode:(NodeType)node2
 	   directed:(BOOL)directed
  		  value:(NSValue *)value;
- (BOOL)connectionExistsFromNode:(NodeType)node1
						  toNode:(NodeType)node2
		 	   			   value:(NSValue *)value;
@property(readonly) NSUInteger connectionsCount;
@property(readonly) NSUInteger directedConnectionsCount;
@property(readonly) NSUInteger inDegreeCount;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNode:(NodeType)node1
			  adjacentToNode:(NodeType)node2
	   				directed:(BOOL)directed
					   value:(NSValue *)value;
@property(readonly) NSUInteger outDegreeCount;
- (void)removeNode:(NodeType)node1
	adjacentToNode:(NodeType)node2
		  directed:(BOOL)directed
  			 value:(NSValue *)value;
@property(readonly) NSUInteger undirectedConnectionsCount;

@end

@interface JVGraphConnectionStore<NodeType> (JVGraphExtendedConnectionStore)

// soon...

@end

@interface JVGraphConnectionStore<NodeType> (JVGraphConnectionStoreCreation)

+ (instancetype)store;
+ (instancetype)storeWithNode:(NodeType)node1
			   adjacentToNode:(NodeType)node2
					 directed:(BOOL)directed
						value:(NSValue *)value;

@end