@interface NSConnectionTest : GHAsyncTestCase

@property ( nonatomic, retain ) id< JNUrlConnection > connection;

@end


@implementation NSConnectionTest

@synthesize connection = _connection;

-(void)dealloc
{
   [ _connection release ];
   
   [ super dealloc ];
}


-(void)testValidDownloadCompletesCorrectly
{
   [ self prepare ];
   
   NSURL* data_url_ = [ [ JNTestBundleManager decodersDataBundle ] URLForResource: @"1" 
                                                                    withExtension: @"txt" ];
   
   JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithUrl: data_url_
                                                                        postData: nil
                                                                         headers: nil ];
   [ factory_ autorelease ];
   

   
   id< JNUrlConnection > connection_ = [ factory_ createStandardConnection ];
   NSMutableData* total_data_ = [ NSMutableData data ];
   NSData* expected_data_ = [ NSData dataWithContentsOfURL: data_url_ ];
   
   connection_.didReceiveResponseBlock = ^( id response_ )
   {
      //IDLE
   };
   connection_.didReceiveDataBlock = ^( NSData* data_chunk_ )
   {
      [ total_data_ appendData: data_chunk_ ];
   };
   
   connection_.didFinishLoadingBlock = ^( NSError* error_ )
   {
      self.connection = nil;

      if ( nil != error_ )
      {
         [ self notify: kGHUnitWaitStatusFailure
           forSelector: _cmd ];
         return;
      }
      
      if ( [ expected_data_ isEqualToData: total_data_ ] )
      {
         [ self notify: kGHUnitWaitStatusSuccess 
           forSelector: _cmd ];
      }
      else
      {
         [ self notify: kGHUnitWaitStatusFailure 
           forSelector: _cmd ];
      }
   };

   self.connection = connection_;
   [ connection_ start ];
   [ self waitForStatus: kGHUnitWaitStatusSuccess
                timeout: 30. ];
}


-(void)testInValidDownloadCompletesWithError
{
   [ self prepare ];
   
   NSURL* data_url_ = [ NSURL URLWithString: @"http://kdjsfhjkfhsdfjkdhfjkds.com" ];
   
   JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithUrl: data_url_
                                                                        postData: nil
                                                                         headers: nil ];
   [ factory_ autorelease ];
   
   
   
   id< JNUrlConnection > connection_ = [ factory_ createStandardConnection ];
   
   connection_.didReceiveResponseBlock = ^( id response_ )
   {
      //IDLE
   };
   connection_.didReceiveDataBlock = ^( NSData* data_chunk_ )
   {
   };
   connection_.didFinishLoadingBlock = ^( NSError* error_ )
   {
      self.connection = nil;

      if ( nil != error_ )
      {
         [ self notify: kGHUnitWaitStatusSuccess 
           forSelector: _cmd ];
         return;
      }
      
      [ self notify: kGHUnitWaitStatusFailure 
        forSelector: _cmd ];
   };
   
   self.connection = connection_;
   [ connection_ start ];
   [ self waitForStatus: kGHUnitWaitStatusSuccess
                timeout: 30. ];
}

@end
