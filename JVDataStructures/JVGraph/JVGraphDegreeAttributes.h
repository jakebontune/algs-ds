#import <Foundation/Foundation.h>

@interface JVGraphDegreeAttributes : NSObject

@property(nonatomic, assign) NSUInteger degree;
- (void)incrementDegree;
- (void)incrementIndegree;
- (void)decrementOutdegree;
- (void)decrementDegree;
- (void)decrementIndegree;
- (void)decrementOutdegree;
@property(nonatomic, assign) NSUInteger indegree;
@property(nonatomic, assign) NSUInteger outdegree;
- (void)updateDegreeWithAmount:(NSInteger)amount;
- (void)updateIndegreeWithAmount:(NSInteger)amount;
- (void)updateOutdegreeWithAmount:(NSInteger)amount;

@end

@interface JVGraphDegreeAttributes (JVExtendedGraphDegreeAttributes)

+ (instancetype)attributes;

@end