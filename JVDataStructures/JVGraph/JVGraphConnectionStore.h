#import <Foundation/Foundation>

typedef NS_ENUM(NSUInteger, JVGraphConnectionStoreRepresentationOptions) {
	JVGraphConnectionStoreRepresentationAdjacencyList,
	JVGraphConnectionStoreRepresentationAdjacencyMatrix,
	JVGraphConnectionStoreRepresentationIncidenceMatrix
};

// Connection Store has the ability to keep track of
// adjacency/incidence metrics in various forms and is able
// to convert between these forms

@interface JVGraphConnectionStore : NSObject



@end