#import "JFFCallbacksBlocks.h"

@implementation JFFCallbacksBlocks

@synthesize onProgressBlock = _on_progress_block;
@synthesize didLoadDataBlock = _did_load_data_block;

-(id)initWithOnProgressBlock:( JFFAsyncOperationProgressHandler )on_progress_block_
            didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_load_data_block_
{
   self = [ super init ];

   if ( self )
   {
      self.onProgressBlock = on_progress_block_;
      self.didLoadDataBlock = did_load_data_block_;
   }

   return self;
}

+(id)callbacksBlocksWithOnProgressBlock:( JFFAsyncOperationProgressHandler )on_progress_block_
                       didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )did_load_data_block_
{
   return [ [ [ self alloc ] initWithOnProgressBlock: on_progress_block_
                                    didLoadDataBlock: did_load_data_block_ ] autorelease ];
}

-(void)dealloc
{
   [ _on_progress_block release ];
   [ _did_load_data_block release ];

   [ super dealloc ];
}

@end
