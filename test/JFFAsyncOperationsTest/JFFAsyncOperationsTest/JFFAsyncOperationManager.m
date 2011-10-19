#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>

@interface JFFAsyncOperationManager ()

@property ( nonatomic, copy ) JFFAsyncOperation loader;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationBlockHolder* loaderFinishBlock;

@property ( nonatomic, assign ) BOOL finished;
@property ( nonatomic, assign ) BOOL canceled;
@property ( nonatomic, assign ) BOOL cancelFlag;

@end

@implementation JFFAsyncOperationManager

@synthesize loader;
@synthesize loaderFinishBlock;
@synthesize finished;
@synthesize canceled;
@synthesize cancelFlag;
@synthesize finishAtLoading;
@synthesize failAtLoading;

-(void)dealloc
{
   [ loader release ];
   [ loaderFinishBlock release ];

   [ super dealloc ];
}

-(id)init
{
   self = [ super init ];

   if ( self )
   {
      loaderFinishBlock = [ JFFDidFinishAsyncOperationBlockHolder new ];
   }

   return self;
}

-(void)clear
{
   self.loader = nil;
   self.loaderFinishBlock = nil;
   self.finished = NO;
}

-(JFFAsyncOperation)loader
{
   if ( !loader )
   {
      __block JFFAsyncOperationManager* self_ = self;
      self.loader = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                             , JFFCancelAsyncOperationHandler cancel_callback_
                                             , JFFDidFinishAsyncOperationHandler done_callback_ )
      {
         done_callback_ = [ done_callback_ copy ];
         self_.loaderFinishBlock.didFinishBlock = ^( id result_, NSError* error_ )
         {
            self_.finished = YES;
            if ( done_callback_ )
               done_callback_( result_, error_ );
         };
         [ done_callback_ release ];

         if ( self_.finishAtLoading || self_.failAtLoading )
         {
            if ( self_.finishAtLoading )
               self_.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );
            else
               self_.loaderFinishBlock.didFinishBlock( nil, [ JFFError errorWithDescription: @"some error" ] );
            return JFFEmptyCancelAsyncOperationBlock;
         }

         JFFCancelAyncOperationBlockHolder* cancel_holder_ = [ [ JFFCancelAyncOperationBlockHolder new ] autorelease ];
         cancel_holder_.cancelBlock = ^( BOOL canceled_ )
         {
            self_.canceled = YES;
            self_.cancelFlag = canceled_;
         };
         return cancel_holder_.onceCancelBlock;
      };
   }
   return loader;
}

@end
