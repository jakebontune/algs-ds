#import <Foundation/Foundation.h>

static NSString * const JVNotAValue = @"NotAValue";
static int const kJV_GRAPH_ZERO_DEFAULT_VALUE = 0;
static int const kJV_GRAPH_DEFAULT_CONNECTION_VALUE = 1;

typedef NS_OPTIONS(NSUInteger, JVGraphConnectionOrientationOptions) {
    JVGraphConnectionOrientationDirected = 5 << 0, // 0000 0101
    JVGraphConnectionOrientationUndirected = 5 << 1, // 0000 1010
};

typedef NS_OPTIONS(NSUInteger, JVGraphNodeOrientationOptions) {
    JVGraphNodeOrientationInitial = 3 << 0, // 0000 0011
    JVGraphNodeOrientationTerminal = 3 << 2, // 0000 1100
};