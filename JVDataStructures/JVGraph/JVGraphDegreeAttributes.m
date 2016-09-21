#import "JVGraphDegreeAttributes.h"

@implementation JVGraphDegreeAttributes {
	NSUInteger _degree;
	NSUInteger _indegree;
	NSUInteger _outdegree;
}

#pragma mark - Creating Degree Attributes

+ (instancetype)attributes {
	return [[JVGraphDegreeAttributes alloc] init];
}

#pragma mark - Querying for Attributes

- (NSUInteger)degree {
	return _degree;
}

- (NSUInteger)indegree {
	return _indegree;
}

- (NSUInteger)outdegree {
	return _outdegree;
}

#pragma mark - Updating Degrees

- (void)incrementDegree {
	++_degree;
}

- (void)incrementIndegree {
	++_indegree;
}

- (void)incrementOutdegree {
	++_outdegree;
}

- (void)decrementDegree {
	--_degree;
}

- (void)decrementIndegree {
	--_indegree;
}

- (void)decrementOutdegree {
	--_outdegree;
}

- (void)updateDegreeWithAmount:(NSInteger)amount {
	_degree += amount;
}

- (void)updateIndegreeWithAmount:(NSInteger)amount {
	_indegree += amount;
}

- (void)updateOutdegreeWithAmount:(NSInteger)amount {
	_outdegree += amount;
}

#pragma mark - NSObject Protocol

- (BOOL)isEqual:(JVGraphDegreeAttributes *)attributes {
	return (_degree == attributes.degree) && (_indegree == attributes.indegree) && (_outdegree == attributes.outdegree) && ([self hash] == [attributes hash]);
}

@end