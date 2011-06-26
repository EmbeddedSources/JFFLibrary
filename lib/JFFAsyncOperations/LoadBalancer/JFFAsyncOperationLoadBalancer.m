#import "JFFAsyncOperationLoadBalancer.h"

@interface JFFContextLoaders : NSObject

@end

@implementation JFFContextLoaders

@end

@interface JFFAsyncOperationLoadBalancer : NSObject

@property ( nonatomic, retain ) NSString* currentContextName;
@property ( nonatomic, retain ) NSMutableDictionary* contextLoadersByName;

+(id)sharedBalancer;

@end

@implementation JFFAsyncOperationLoadBalancer

@synthesize currentContextName = _current_context_name;
@synthesize contextLoadersByName = _context_loaders_by_name;

-(void)dealloc
{
   [ _current_context_name release ];
   [ _context_loaders_by_name release ];

   [ super dealloc ];
}

-(NSString*)currentContextName
{
   if ( !_current_context_name )
   {
      _current_context_name = [ @"default" retain ];
   }
   return _current_context_name;
}

-(NSMutableDictionary*)contextLoadersByName
{
   if ( !_context_loaders_by_name )
   {
      _context_loaders_by_name = [ NSMutableDictionary new ];
   }
   return _context_loaders_by_name;
}

+(id)sharedBalancer
{
   static JFFAsyncOperationLoadBalancer* instance_ = nil;

   if ( !instance_ )
   {
      instance_ = [ self new ];
   }

   return instance_;
}

@end

static JFFAsyncOperationLoadBalancer* sharedBalancer()
{
   return [ JFFAsyncOperationLoadBalancer sharedBalancer ];
}

void setBalancerCurrentContextName( NSString* context_name_ )
{
   sharedBalancer().currentContextName = context_name_;
}

JFFAsyncOperation balancedAsyncOperation( JFFAsyncOperation loader_ )
{
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelAsyncOperationHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      JFFCancelAsyncOperation cancel_block_ = loader_( progress_callback_, cancel_callback_, done_callback_ );

      return [ [ ^( BOOL canceled_ )
      {
         cancel_block_( canceled_ );
      } copy ] autorelease ];
   } copy ] autorelease ];
}
