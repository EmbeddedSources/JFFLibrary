#import <JFFNetwork/JNUrlConnection.h>
#import <Foundation/Foundation.h>


@interface JNAbstractConnection : NSObject < JNUrlConnection >

@property ( nonatomic, copy ) ESDidReceiveResponseHandler didReceiveResponseBlock;
@property ( nonatomic, copy ) ESDidReceiveDataHandler     didReceiveDataBlock    ;
@property ( nonatomic, copy ) ESDidFinishLoadingHandler   didFinishLoadingBlock  ;

-(void)clearCallbacks;

@end
