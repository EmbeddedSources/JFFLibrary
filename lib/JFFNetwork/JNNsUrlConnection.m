#import "JNNsUrlConnection.h"
#import "JNAbstractConnection+Constructor.h"


@interface JNNsUrlConnection ()

@property ( nonatomic, retain ) NSURLConnection* nativeConnection;

@end


@implementation JNNsUrlConnection

@synthesize nativeConnection = _native_connection;

-(void)dealloc
{
   [ _native_connection release ];
   [ super dealloc ];
}

-(id)initWithRequest:( NSURLRequest* )request_
{
   self = [ super privateInit ];
   if ( nil == self )
   {
      return nil;
   }

   {
      //!c self is retained by native_connection_
      //TODO : break the cycle
      NSURLConnection* native_connection_ = [ [ NSURLConnection alloc ] initWithRequest: request_
                                                                               delegate: self
                                                                       startImmediately: NO ];
      self.nativeConnection = native_connection_;
      [ native_connection_ release ];
   }

   return self;
}

#pragma mark -
#pragma mark JNUrlConnection
-(void)start
{
   [ self.nativeConnection start ];
}

-(void)cancel
{
   [ self clearCallbacks ];
   [ self.nativeConnection cancel ];
}


#pragma mark -
#pragma mark NSUrlConnectionDelegate
-(BOOL)assertConnectionMismatch:( NSURLConnection* )connection_
{
   BOOL is_connection_mismatch_ = ( connection_ != self.nativeConnection );
   if ( is_connection_mismatch_ )
   {
      //!c TODO : handle this properly
      NSLog( @"JNNsUrlConnection : connection mismatch" );
      NSAssert( NO, @"JNNsUrlConnection : connection mismatch" );
      return NO;
   }
   
   return YES;
}


-(void)connection:( NSURLConnection* )connection_
didReceiveResponse:( NSHTTPURLResponse* )response_
{
   if ( ![ self assertConnectionMismatch: connection_ ] )
   {
      return;
   }
   
   if ( nil != self.didReceiveResponseBlock )
   {
      self.didReceiveResponseBlock( response_ );
   }
}

-(void)connection:( NSURLConnection* )connection_
   didReceiveData:( NSData* )chunk_
{
   if ( ![ self assertConnectionMismatch: connection_ ] )
   {
      return;
   }
   
   if ( nil != self.didReceiveDataBlock )
   {
      self.didReceiveDataBlock( chunk_ );
   }
}

-(void)connectionDidFinishLoading:( NSURLConnection* )connection_
{
   if ( ![ self assertConnectionMismatch: connection_ ] )
   {
      return;
   }
   
   if ( nil != self.didFinishLoadingBlock )
   {
      self.didFinishLoadingBlock( nil );
      [ self cancel ];
   }
}

@end
