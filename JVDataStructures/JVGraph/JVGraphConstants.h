#import <Foundation/Foundation.h>

static int const kJV_GRAPH_DEFAULT_VALUE_ZERO = 0;
static int const kJV_GRAPH_DEFAULT_SELF_LOOP_DEGREE = 2;
static int const kJV_GRAPH_DEFAULT_VALUE_ONE = 1;
static int const kJV_GRAPH_DEFAULT_CONNECTION_VALUE = 1;

typedef NS_OPTIONS(NSUInteger, JVGraphConnectionOrientationOptions) {
    JVGraphConnectionOrientationDirected = 5 << 0, // 0000 0101
    JVGraphConnectionOrientationUndirected = 5 << 1, // 0000 1010
};

typedef NS_OPTIONS(NSUInteger, JVGraphNodeOrientationOptions) {
    JVGraphNodeOrientationInitial = 3 << 0, // 0000 0011
    JVGraphNodeOrientationTerminal = 3 << 2, // 0000 1100
};