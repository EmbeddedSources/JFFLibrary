#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

@class NSArray;

///////////////////////////////////// SEQUENCE /////////////////////////////////////

JFFAsyncOperation sequenceOfAsyncOperations( JFFAsyncOperation first_loader_
                                            , JFFAsyncOperation second_loader_, ... );

JFFAsyncOperation sequenceOfAsyncOperationsArray( NSArray* blocks_ );

/////////////////////////////////// TRY SEQUENCE ///////////////////////////////////

JFFAsyncOperation trySequenceOfAsyncOperations( JFFAsyncOperation first_loader_
                                               , JFFAsyncOperation second_loader_, ... );

/////////////////////////////////////// GROUP //////////////////////////////////////

JFFAsyncOperation groupOfAsyncOperations( JFFAsyncOperation first_loader_
                                         , JFFAsyncOperation second_loader_, ... );

JFFAsyncOperation groupOfAsyncOperationsArray( NSArray* blocks_ );

///////////////////////////// FAIL ON FIRST ERROR GROUP ////////////////////////////

JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperations( JFFAsyncOperation first_loader_
                                                         , JFFAsyncOperation second_loader_, ... );

JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsArray( NSArray* blocks_ );

///////////////////////// ADD OBSERVERS OF ASYNC OP. RESULT ////////////////////////

JFFAsyncOperation asyncOperationWithDoneCallbackBlock( JFFAsyncOperation loader_
                                                      , JFFDidFinishAsyncOperationHandler done_callback_block_ );

JFFAsyncOperation asyncOperationWithDoneHookBlock( JFFAsyncOperation loader_
                                                  , JFFDidFinishAsyncOperationHook done_callback_hook_ );
