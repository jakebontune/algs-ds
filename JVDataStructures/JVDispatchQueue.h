#import <Foundation/Foundation.h>

// goo.gl/KVEwuI
// A dispatch queue is a queue of jobs backed by a global thread pool.
// Typically, jobs submitted to a queue are executed asynchronously
// on a background thread. All threads share a single pool of
// background threads, which makes the system more efficient.
@interface JVDispatchQueue : NSObject

- (void)dispatchAsync:(dispatch_block_t)block;
- (void)dispatchSync:(dispatch_block_t)block;
+(JVDispatchQueue *)globalQueue;
- (id)initSerial:(BOOL)serial;

@end