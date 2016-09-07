#import <Foundation/Foundation.H>

@interface JVLinearNode : NSObject

@property (nonatomic, strong) id element;
- (instancetype)initWithElement:(id)element;
+ (instancetype)nodeWithElement:(id)element;

@end