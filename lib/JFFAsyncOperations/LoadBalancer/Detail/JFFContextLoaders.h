#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFContextLoaders : NSObject
{
@private
   NSMutableArray* _pending_loaders;
   NSMutableArray* _active_loaders_data;
   NSString* _name;
}

@property ( nonatomic, assign, readonly ) NSUInteger activeLoadersNumber;
@property ( nonatomic, retain ) NSMutableArray* pendingLoaders;
@property ( nonatomic, retain ) NSMutableArray* activeLoadersData;
@property ( nonatomic, retain ) NSString* name;

-(void)addActiveNativeLoader:( JFFAsyncOperation )native_loader_
               wrappedCancel:( JFFCancelAsyncOperation )cancel_;

-(BOOL)removeNativeLoader:( JFFAsyncOperation )native_loader_;

-(void)cancelNativeLoader:( JFFAsyncOperation )native_loader_ cancel:( BOOL )canceled_;

@end
