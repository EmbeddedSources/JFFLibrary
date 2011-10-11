#import "JNAbstractConnection.h"


@implementation JNAbstractConnection

@synthesize didReceiveResponseBlock = _did_receive_response_block;
@synthesize didReceiveDataBlock     = _did_receive_data_block    ;
@synthesize didFinishLoadingBlock   = _did_finish_loading_block  ;

-(void)dealloc
{
   [ _did_receive_response_block release ];
   [ _did_receive_data_block     release ];
   [ _did_finish_loading_block   release ];
   
   [ super dealloc ];
}

#pragma mark -
#pragma mark Not Supported
-(void)start
{
   NSLog( @"[!!! ERROR !!!] : JNAbstractConnection->start is not supported. Please subclass it." );
   [ self doesNotRecognizeSelector: _cmd ];
}

-(void)cancel
{
   NSLog( @"[!!! ERROR !!!] : JNAbstractConnection->cancel is not supported. Please subclass it." );
   [ self doesNotRecognizeSelector: _cmd ];
}

-(id)init
{
   NSLog( @"[!!! ERROR !!!] : JNAbstractConnection->init is not supported. Consider using a 'privateInit' method" );

   [ self doesNotRecognizeSelector: _cmd ];
   return nil;
}

#pragma mark -
#pragma mark Callbacks management
-(void)clearCallbacks
{
   self.didReceiveResponseBlock = nil;
   self.didReceiveDataBlock     = nil;
   self.didFinishLoadingBlock   = nil;
}

@end
