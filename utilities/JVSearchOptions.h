#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, JVBinarySearchingOptions) {
	JVBinarySearchingFirstEqual = (1UL << 8),
	JVBinarySearchingLastEqual = (1UL << 9),
	JVBinarySearchingInsertionIndex = (1ul << 10),
};