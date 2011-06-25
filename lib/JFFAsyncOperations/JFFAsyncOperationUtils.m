#import "JFFAsyncOperationUtils.h"

#import "JFFBlockOperation.h"

#import <JFFUtils/NSObject/NSObject+PerformBlock.h>

@interface JFFAsyncOperationProgressBlockHolder : NSObject
{
@private
   JFFAsyncOperationProgressHandler _progress_block;
}

@property ( nonatomic, copy ) JFFAsyncOperationProgressHandler progressBlock;

+(id)asyncOperationProgressBlockHolder;

-(void)performBlockOnceWithArgument:( id )object_;

@end

@implementation JFFAsyncOperationProgressBlockHolder

@synthesize progressBlock = _progress_block;

-(void)dealloc
{
   [ _progress_block release ];

   [ super dealloc ];
}

+(id)asyncOperationProgressBlockHolder
{
   return [ [ [ self alloc ] init ] autorelease ];
}

-(void)performBlockOnceWithArgument:( id )object_
{
   if ( !self.progressBlock )
      return;

   JFFAsyncOperationProgressHandler block_ = [ self.progressBlock copy ];
   self.progressBlock = nil;
   block_( object_ );
   [ block_ release ];
}

@end

JFFAsyncOperation asyncOperationWithSyncOperation( JFFSyncOperation load_data_block_ )
{
   load_data_block_ = [ [ load_data_block_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler pregress_info_callback_
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFBlockOperation* operation_ = [ JFFBlockOperation performOperationWithLoadDataBlock: load_data_block_
                                                                             didCancelBlock: cancel_callback_
                                                                           didLoadDataBlock: done_callback_ ];
      return [ [ ^( BOOL cancel_ )
      {
         [ operation_ cancel: cancel_ ];
      } copy ] autorelease ];
   } copy ] autorelease ];
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progress_load_data_block_ )
{
   progress_load_data_block_ = [ [ progress_load_data_block_ copy ] autorelease ];
   return [ [ ^( JFFAsyncOperationProgressHandler pregress_info_callback_
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFAsyncOperationProgressBlockHolder* holder_ = [ JFFAsyncOperationProgressBlockHolder asyncOperationProgressBlockHolder ];
      holder_.progressBlock = ^( id progress_info_ )
      {
         [ ^
         {
            pregress_info_callback_( progress_info_ );
         } performBlockOnMainThread ];
      };

      JFFSyncOperation load_data_block_ = ^( NSError** error_ )
      {
         JFFAsyncOperationProgressHandler thread_progress_load_data_block_ = ^( id progress_info_ )
         {
            if ( holder_.progressBlock )
               holder_.progressBlock( progress_info_ );
         };
         return (id)progress_load_data_block_( error_, thread_progress_load_data_block_ );
      };
      JFFBlockOperation* operation_ = [ JFFBlockOperation performOperationWithLoadDataBlock: load_data_block_
                                                                             didCancelBlock: cancel_callback_
                                                                           didLoadDataBlock: done_callback_ ];
      return [ [ ^( BOOL cancel_ )
      {
         holder_.progressBlock = nil;
         [ operation_ cancel: cancel_ ];
      } copy ] autorelease ];
   } copy ] autorelease ];
}
