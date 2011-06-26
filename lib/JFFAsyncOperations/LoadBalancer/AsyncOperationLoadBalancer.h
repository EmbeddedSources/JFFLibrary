#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface AsyncOperationLoadBalancer : NSObject
{

}

@end

JFFAsyncOperation balancedAsyncOperation( JFFAsyncOperation loader_ );
