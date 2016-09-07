#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support"
#endif

#import "JVDispatchQueue.h"
#import "JVQueue.h"

@interface JVThreadPool : NSObject

- (void)addBlock:(dispatch_block_t)block;

@end

@implementation JVDispatchQueue



@end