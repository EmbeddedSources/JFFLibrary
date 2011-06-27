#import <Foundation/Foundation.h>

@interface JFFOperationQueue : NSObject
{
@private
   NSOperationQueue* _queue;
}

+(JFFOperationQueue*)sharedQueue;

-(void)addOperation:( NSOperation* )operation_;

@end
