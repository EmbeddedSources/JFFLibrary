#import "JFFBlockOperation.h"

#import "JFFOperationQueue.h"

@interface JFFBlockOperation ()

@property ( copy ) JFFSyncOperation loadDataBlock;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didLoadDataBlock;

@end

@implementation JFFBlockOperation

@synthesize loadDataBlock = _load_data_block;
@synthesize didLoadDataBlock = _did_load_data_block;

-(void)dealloc
{
   NSAssert( !_did_load_data_block, @"should be nil" );
   [ _load_data_block release ];

   [ super dealloc ];
}

-(id)initWithLoadDataBlock:( JFFSyncOperation )load_data_block_
          didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_load_data_block_
{
   self = [ super init ];

   if ( self )
   {
      self.loadDataBlock      = load_data_block_;
      self.didLoadDataBlock   = did_load_data_block_;
   }

   return self;
}

+(id)performOperationWithLoadDataBlock:( JFFSyncOperation )load_data_block_
                      didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_load_data_block_
{
   id operation_ = [ [ self alloc ] initWithLoadDataBlock: load_data_block_
                                         didLoadDataBlock: did_load_data_block_];

   [ [ JFFOperationQueue sharedQueue ] addOperation: operation_ ];

   return [ operation_ autorelease ];
}

-(void)didFinishOperationWithResultContext:( JFFResultContext* )result_context_
{
   if ( !self.didLoadDataBlock )
      return;

   JFFDidFinishAsyncOperationHandler did_load_data_block_ = [ self.didLoadDataBlock copy ];
   self.didLoadDataBlock = nil;
   did_load_data_block_( result_context_.result, result_context_.error );
   [ did_load_data_block_ release ];
}

-(void)cancel:( BOOL )cancel_
{
   [ NSThread assertMainThread ];

   if ( cancel_ )
      [ super cancel ];

   self.didLoadDataBlock = nil;
}

-(void)main
{
   NSAutoreleasePool* pool_ = [ NSAutoreleasePool new ];

   JFFResultContext* result_context_ = [ [ JFFResultContext new ] autorelease ];

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
      JFFError* error_ = [ JFFError errorWithDescription: [ NSString stringWithFormat: @"exception: %@, reason: %@", ex_.name, ex_.reason ] ];
      result_context_.error = error_;
   }

   [ self performSelectorOnMainThread: @selector( didFinishOperationWithResultContext: )
                           withObject: result_context_
                        waitUntilDone: YES ];

   [ pool_ release ];
}

@end
