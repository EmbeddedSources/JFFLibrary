#import "JFFCallbacksBlocksHolder.h"

@implementation JFFCallbacksBlocksHolder

@synthesize onProgressBlock;
@synthesize onCancelBlock;
@synthesize didLoadDataBlock;

-(id)initWithOnProgressBlock:( JFFAsyncOperationProgressHandler )on_progress_block_
               onCancelBlock:( JFFCancelAsyncOperationHandler )on_cancel_block_
            didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_load_data_block_
{
   self = [ super init ];

   if ( self )
   {
      self.onProgressBlock = on_progress_block_;
      self.onCancelBlock = on_cancel_block_;
      self.didLoadDataBlock = did_load_data_block_;
   }

   return self;
}

@end
