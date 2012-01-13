#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@protocol SCMonad < NSObject >

@required
typedef id< SCMonad > (^SCNextOp) (id result);
- (id<SCMonad>)bind:(SCNextOp)nextOp;

+ (id<SCMonad>)construct:(id)value;

@end

@interface JFFAsyncMonad : NSObject <SCMonad>

@property(nonatomic,copy,readonly) JFFAsyncOperation asyncOp;

+ (JFFAsyncMonad *)monadWithValue:(id)value;
+ (JFFAsyncMonad *)monadWithError:(NSError *)error;
+ (JFFAsyncMonad *)monadWithAsyncOp:(JFFAsyncOperation)asyncOp;

@end
