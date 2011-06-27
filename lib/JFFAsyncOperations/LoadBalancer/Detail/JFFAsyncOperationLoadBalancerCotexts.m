#import "JFFAsyncOperationLoadBalancerCotexts.h"

#import "JFFContextLoaders.h"

@implementation JFFAsyncOperationLoadBalancerCotexts

@synthesize currentContextName = _current_context_name;
@synthesize activeContextName = _active_context_name;
@synthesize contextLoadersByName = _context_loaders_by_name;

-(void)dealloc
{
   [ _current_context_name release ];
   [ _active_context_name release ];
   [ _context_loaders_by_name release ];

   [ super dealloc ];
}

-(NSString*)currentContextName
{
   if ( !_current_context_name )
   {
      _current_context_name = [ self.currentContextName retain ];
   }
   return _current_context_name;
}

-(NSString*)activeContextName
{
   if ( !_active_context_name )
   {
      _active_context_name = [ @"default" retain ];
   }
   return _active_context_name;
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
   static JFFAsyncOperationLoadBalancerCotexts* instance_ = nil;

   if ( !instance_ )
   {
      instance_ = [ self new ];
   }

   return instance_;
}

-(JFFContextLoaders*)currentContextLoaders
{
   JFFContextLoaders* result_ = [ self.contextLoadersByName objectForKey: self.currentContextName ];
   if ( !result_ )
   {
      result_ = [ JFFContextLoaders new ];
      result_.name = self.currentContextName;

      [ result_ setValue: result_ forKey: self.currentContextName ];

      [ result_ release ];
   }
   return result_;
}

@end
