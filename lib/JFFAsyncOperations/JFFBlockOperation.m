#import "JFFBlockOperation.h"

#import "JFFOperationQueue.h"
#import "JFFResultContext.h"

#import <JFFUtils/JFFError.h>
#import <JFFUtils/NSThread+AssertMainThread.h>

@interface JFFBlockOperation ()

@property ( copy ) JFFSyncOperation loadDataBlock;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didLoadDataBlock;
@property ( nonatomic, copy ) JFFCancelHandler cancelBlock;
@property ( nonatomic, assign ) NSOperationQueue* operationQueue;

@end

@implementation JFFBlockOperation

@synthesize loadDataBlock = _load_data_block;
@synthesize didLoadDataBlock = _did_load_data_block;
@synthesize operationQueue = _operation_queue;
@synthesize cancelBlock = _cancel_block;

-(void)dealloc
{
   NSAssert( !_did_load_data_block, @"should be nil" );
   [ _load_data_block release ];
   [ _cancel_block release ];

   [ super dealloc ];
}

-(id)initWithLoadDataBlock:( JFFSyncOperation )load_data_block_
            didCancelBlock:( JFFCancelHandler )cancel_block_
          didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_load_data_block_
{
   self = [ super init ];

   if ( self )
   {
      self.loadDataBlock = load_data_block_;
      self.cancelBlock = cancel_block_;
      self.didLoadDataBlock = did_load_data_block_;
   }

   return self;
}

+(id)performOperationWithLoadDataBlock:( JFFSyncOperation )load_data_block_
                        didCancelBlock:( JFFCancelHandler )cancel_block_
                      didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_load_data_block_
{
   id operation_ = [ [ self alloc ] initWithLoadDataBlock: load_data_block_
                                           didCancelBlock: cancel_block_
                                         didLoadDataBlock: did_load_data_block_];

   [ [ JFFOperationQueue sharedQueue ] addOperation: operation_ ];

   return [ operation_ autorelease ];
}

-(void)didFinishOperationWithResultContext:( JFFResultContext* )result_context_
{
   if ( !self.didLoadDataBlock )
      return;

   JFFOperationQueue* shared_queue_ = [ JFFOperationQueue sharedQueue ];
   NSOperationQueue* current_queue_ = [ shared_queue_ currentContextQueue ];

   [ shared_queue_ setCurrentContextQueue: self.operationQueue ];

   self.cancelBlock = nil;

   JFFDidFinishAsyncOperationHandler did_load_data_block_ = [ self.didLoadDataBlock copy ];
   self.didLoadDataBlock = nil;
   did_load_data_block_( result_context_.result, result_context_.error );
   [ did_load_data_block_ release ];

   [ shared_queue_ setCurrentContextQueue: current_queue_ ];
}

-(void)cancel
{
   [ NSThread assertMainThread ];

   [ super cancel ];

   self.didLoadDataBlock = nil;

   if ( self.cancelBlock )
   {
      self.cancelBlock();
      self.cancelBlock = nil;
   }
}

-(void)main
{
   NSAutoreleasePool* pool_ = [ [ NSAutoreleasePool alloc ] init ];

   JFFResultContext* result_context_ = [ [ [ JFFResultContext alloc ] init ] autorelease ];

   @try
   {
      NSError* local_error_ = nil;
      result_context_.result = self.loadDataBlock( &local_error_ );
      result_context_.error = local_error_;
   }
   @catch ( NSException* ex_ )
   {
      NSLog( @"critical error: %@", ex_ );
      result_context_.result = nil;
      result_context_.error = [ JFFError errorWithDescription: [ NSString stringWithFormat: @"exception: %@, reason: %@", ex_.name, ex_.reason ] ];
   }

   [ self performSelectorOnMainThread: @selector( didFinishOperationWithResultContext: )
                           withObject: result_context_
                        waitUntilDone: YES ];

   [ pool_ release ];
}

@end
