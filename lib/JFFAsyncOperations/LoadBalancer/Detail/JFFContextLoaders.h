#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFContextLoaders : NSObject
{
@private
   NSUInteger _active_loaders_number;
   NSMutableArray* _pending_loaders;
   NSMutableArray* _active_loaders_data;
   NSString* _name;
}

@property ( nonatomic, assign ) NSUInteger activeLoadersNumber;
@property ( nonatomic, retain ) NSMutableArray* pendingLoaders;
@property ( nonatomic, retain ) NSMutableArray* activeLoadersData;
@property ( nonatomic, retain ) NSString* name;

-(void)addActiveNativeLoader:( JFFAsyncOperation )loader_
               wrappedCancel:( JFFCancelAsyncOperation )cancel_;

-(void)cancelNativeLoader:( JFFAsyncOperation )native_loader_ cancel:( BOOL )canceled_;

@end
