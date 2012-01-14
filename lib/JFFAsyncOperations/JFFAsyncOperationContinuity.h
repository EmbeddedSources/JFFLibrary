#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

@class NSArray;

///////////////////////////////////// SEQUENCE /////////////////////////////////////

//calls loaders while success
JFFAsyncOperation sequenceOfAsyncOperations( JFFAsyncOperation firstLoader_
                                            , JFFAsyncOperation secondLoader_, ... );

JFFAsyncOperation sequenceOfAsyncOperationsArray( NSArray* loaders_ );

/////////////////////////////////// TRY SEQUENCE ///////////////////////////////////

//calls loaders untill success
JFFAsyncOperation trySequenceOfAsyncOperations( JFFAsyncOperation firstLoader_
                                               , JFFAsyncOperation secondLoader_, ... );

JFFAsyncOperation trySequenceOfAsyncOperationsArray( NSArray* loaders_ );

/////////////////////////////////////// GROUP //////////////////////////////////////

//calls finish callback when all loaders finished
//result of group is undefined for success result
JFFAsyncOperation groupOfAsyncOperations( JFFAsyncOperation firstLoader_, ... );

JFFAsyncOperation groupOfAsyncOperationsArray( NSArray* loaders_ );

///////////////////////////// FAIL ON FIRST ERROR GROUP ////////////////////////////

//calls finish callback when all loaders success finished or when any of them is failed
//result of group is undefined for success result
JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperations( JFFAsyncOperation firstLoader_, ... );

JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsArray( NSArray* loaders_ );

///////////////////////// ADD OBSERVERS OF ASYNC OP. RESULT ////////////////////////

//finish_callback_block_ called before loader_'s JFFDidFinishAsyncOperationHandler
JFFAsyncOperation asyncOperationWithFinishCallbackBlock( JFFAsyncOperation loader_
                                                        , JFFDidFinishAsyncOperationHandler finishCallbackBlock_ );

//finish_callback_hook_ called instead loader_'s JFFDidFinishAsyncOperationHandler
JFFAsyncOperation asyncOperationWithFinishHookBlock( JFFAsyncOperation loader_
                                                    , JFFDidFinishAsyncOperationHook finishCallbackHook_ );

//done_callback_hook_ called an cancel or finish loader_'s callbacks
JFFAsyncOperation asyncOperationWithDoneBlock( JFFAsyncOperation loader_
                                              , JFFSimpleBlock doneCallbackHook_ );

JFFAsyncOperation asyncOperationWithResult( id result_ );
JFFAsyncOperation asyncOperationWithError( id result_ );

///////////////////////// AUTO REPEAT CIRCLE ////////////////////////

JFFAsyncOperation repeatAsyncOperation( JFFAsyncOperation loader_
                                       , PredicateBlock predicate_
                                       , NSTimeInterval delay_
                                       , NSInteger max_repeat_count_ );

JFFAsyncOperation asyncOperationAfterDelay( NSTimeInterval delay_
                                           , JFFAsyncOperation loader_ );
