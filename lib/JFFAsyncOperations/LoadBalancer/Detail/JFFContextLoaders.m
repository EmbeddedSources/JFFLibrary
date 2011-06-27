#import "JFFContextLoaders.h"

#import "JFFActiveLoaderData.h"

#import <JFFUtils/NSArray/NSArray+BlocksAdditions.h>

@implementation JFFContextLoaders

@synthesize activeLoadersNumber = _active_loaders_number;
@synthesize pendingLoaders = _pending_loaders;
@synthesize activeLoadersData = _active_loaders_data;
@synthesize name = _name;

-(void)dealloc
{
   [ _pending_loaders release ];
   [ _active_loaders_data release ];
   [ _name release ];

   [ super dealloc ];
}

-(NSMutableArray*)pendingLoaders
{
   if ( !_pending_loaders )
   {
      _pending_loaders = [ NSMutableArray new ];
   }
   return _pending_loaders;
}

-(NSMutableArray*)activeLoadersData
{
   if ( !_active_loaders_data )
   {
      _active_loaders_data = [ NSMutableArray new ];
   }
   return _active_loaders_data;
}

-(void)addActiveNativeLoader:( JFFAsyncOperation )loader_
               wrappedCancel:( JFFCancelAsyncOperation )cancel_
{
   JFFActiveLoaderData* data_ = [ JFFActiveLoaderData new ];
   data_.nativeLoader = loader_;
   data_.wrappedCancel = cancel_;

   [ self.activeLoadersData addObject: data_ ];

   [ data_ release ];
}

-(void)cancelNativeLoader:( JFFAsyncOperation )native_loader_ cancel:( BOOL )canceled_
{
   JFFActiveLoaderData* data_ = [ self.activeLoadersData firstMatch: ^( id object_ )
   {
      JFFAsyncOperation loader_ = object_;
      return (BOOL)( loader_ == native_loader_ );
   } ];

   if ( data_ )
      data_.wrappedCancel( canceled_ );
}

@end
