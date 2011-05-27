#import <JFFBlockUtils/JFFBlocksDefinitions.h>

@class NSArray;

/////////////////////////////////// SEQUENCE ///////////////////////////////////

JFFAsyncOperation sequenceOfAsyncOperations( JFFAsyncOperation first_loader_
                                            , JFFAsyncOperation second_loader_, ... );

JFFAsyncOperation sequenceOfAsyncOperationsArray( NSArray* blocks_ );

/////////////////////////////////// TRY SEQUENCE ///////////////////////////////////

JFFAsyncOperation trySequenceOfAsyncOperations( JFFAsyncOperation first_loader_
                                               , JFFAsyncOperation second_loader_, ... );

/////////////////////////////////// GROUP ///////////////////////////////////

JFFAsyncOperation groupOfAsyncOperations( JFFAsyncOperation first_loader_
                                         , JFFAsyncOperation second_loader_, ... );

JFFAsyncOperation groupOfAsyncOperationsArray( NSArray* blocks_ );

JFFAsyncOperation loaderBlockFailOnFirstErrorWithBlocksGroup( JFFAsyncOperation first_loader_
                                                             , JFFAsyncOperation second_loader_, ... );
JFFAsyncOperation loaderBlockFailOnFirstErrorWithBlocksGroupArray( NSArray* blocks_ );

JFFAsyncOperation loaderBlockWithDoneCallbackBlock( JFFAsyncOperation loader_
                                                   , JFFDidFinishAsyncOperationHandler done_callback_block_ );
JFFAsyncOperation loaderBlockWithDoneHookBlock( JFFAsyncOperation loader_
                                               , JFFDidFinishAsyncOperationHook done_callback_hook_ );
