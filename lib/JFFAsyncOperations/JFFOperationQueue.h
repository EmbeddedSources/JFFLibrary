#import <Foundation/Foundation.h>

@interface JFFOperationQueue : NSObject
{
@private
   NSMutableDictionary* _queues;
   NSOperationQueue* _global_queue;
   NSOperationQueue* _current_queue;
}

+(JFFOperationQueue*)sharedQueue;

-(void)setContextName:( NSString* )context_name_;

-(void)setCurrentContextQueue:( NSOperationQueue* )queue_;
-(NSOperationQueue*)currentContextQueue;

-(void)addOperation:( NSOperation* )operation_;
-(void)addOperationToGlobalQueue:( NSOperation* )operation_;

@end
