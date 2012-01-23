#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@protocol JFFMonad < NSObject >

@required
typedef id< JFFMonad > (^JFFNextOp) (id result);
- (id<JFFMonad>)bind:(JFFNextOp)nextOp;

+ (id<JFFMonad>)construct:(id)value;

@end

@interface JFFAsyncMonad : NSObject <JFFMonad>

@property(nonatomic,copy,readonly) JFFAsyncOperation asyncOp;

+ (JFFAsyncMonad *)monadWithValue:(id)value;
+ (JFFAsyncMonad *)monadWithError:(NSError *)error;
+ (JFFAsyncMonad *)monadWithAsyncOp:(JFFAsyncOperation)asyncOp;

@end
