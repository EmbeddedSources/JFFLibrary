#import "JFFDidFinishAsyncOperationBlockHolder.h"

@implementation JFFDidFinishAsyncOperationBlockHolder

@synthesize didFinishBlock = _did_finish_blcok;

-(void)dealloc
{
   [ _did_finish_blcok release ];

   [ super dealloc ];
}

+(id)didFinishAyncOperationBlockHolder
{
   return [ [ self new ] autorelease ];
}

-(void)performDidFinishBlockOnceWithResult:( id )result_ error:( NSError* )error_
{
   if ( !self.didFinishBlock )
      return;

   JFFDidFinishAsyncOperationHandler block_ = [ self.didFinishBlock copy ];
   self.didFinishBlock = nil;
   block_( result_, error_ );
   [ block_ release ];
}

-(JFFDidFinishAsyncOperationHandler)onceDidFinishBlock
{
   return [ [ ^( id result_, NSError* error_ )
   {
      [ self performDidFinishBlockOnceWithResult: result_ error: error_ ];
   } copy ] autorelease ];
}

@end
