#import <JFFNetwork/JNUrlConnectionCallbacks.h>
#import <Foundation/Foundation.h>



@protocol JNUrlConnection

@required
   -(void)start;
   -(void)cancel;

@required
   //callbacks cleared after finish of loading
   @property ( nonatomic, copy ) ESDidReceiveResponseHandler didReceiveResponseBlock;
   @property ( nonatomic, copy ) ESDidReceiveDataHandler     didReceiveDataBlock    ;
   @property ( nonatomic, copy ) ESDidFinishLoadingHandler   didFinishLoadingBlock  ;

@end
