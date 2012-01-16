#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@protocol JFFAsyncMonad < NSObject >

@required
typedef id< JFFAsyncMonad > (^JFFNextOp) (id result);
- (id<JFFAsyncMonad>)bind:(JFFNextOp)nextOp;

+ (id<JFFAsyncMonad>)construct:(id)value;

@end

@interface JFFAsyncMonad : NSObject <JFFAsyncMonad>

@property(nonatomic,copy,readonly) JFFAsyncOperation asyncOp;

+ (JFFAsyncMonad *)monadWithValue:(id)value;
+ (JFFAsyncMonad *)monadWithError:(NSError *)error;
+ (JFFAsyncMonad *)monadWithAsyncOp:(JFFAsyncOperation)asyncOp;

@end
