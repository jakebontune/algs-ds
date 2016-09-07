#import <Foundation/Foundation>

typedef NS_ENUM(NSUInteger, JVAdjacencyStoreRepresentationOptions) {
	JVAdjacencyStoreRepresentationAdjacencyList,
	JVAdjacencyStoreRepresentationAdjacencyMatrix,
	JVAdjacencyStoreRepresentationIncidenceMatrix
};

// Adjacency Store has the ability to keep track of adjacency
// metrics in various forms and is able to convert between these
// forms

@interface JVAdjacencyStore : NSObject



@end