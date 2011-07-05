#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

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

//finish_callback_block_ called before loader_'s JFFDidFinishAsyncOperationHandler
JFFAsyncOperation asyncOperationWithFinishCallbackBlock( JFFAsyncOperation loader_
                                                        , JFFDidFinishAsyncOperationHandler finish_callback_block_ );

//finish_callback_hook_ called instead loader_'s JFFDidFinishAsyncOperationHandler
JFFAsyncOperation asyncOperationWithFinishHookBlock( JFFAsyncOperation loader_
                                                    , JFFDidFinishAsyncOperationHook finish_callback_hook_ );

//done_callback_hook_ called an cancel or finish loader_'s callbacks
JFFAsyncOperation asyncOperationWithDoneBlock( JFFAsyncOperation loader_
                                              , JFFSimpleBlock done_callback_hook_ );
