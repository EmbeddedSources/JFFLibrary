#import <JFFBlockUtils/JFFBlocksDefinitions.h>

@class NSArray;

JFFAsyncOperation sequenceOfAsyncOperations( JFFAsyncOperation first_loader_
                                            , JFFAsyncOperation second_loader_, ... );

JFFAsyncOperation sequenceOfAsyncOperationsArray( NSArray* blocks_ );

JFFAsyncOperation trySequenceOfAsyncOperations( JFFAsyncOperation first_loader_
                                               , JFFAsyncOperation second_loader_, ... );

JFFAsyncOperation loaderBlockWithBlocksGroup( JFFAsyncOperation first_loader_
                                             , JFFAsyncOperation second_loader_, ... );
JFFAsyncOperation loaderBlockWithBlocksGroupArray( NSArray* blocks_ );

JFFAsyncOperation loaderBlockFailOnFirstErrorWithBlocksGroup( JFFAsyncOperation first_loader_
                                                             , JFFAsyncOperation second_loader_, ... );
JFFAsyncOperation loaderBlockFailOnFirstErrorWithBlocksGroupArray( NSArray* blocks_ );

JFFAsyncOperation loaderBlockWithDoneCallbackBlock( JFFAsyncOperation loader_
                                                   , JFFDidFinishAsyncOperationHandler done_callback_block_ );
JFFAsyncOperation loaderBlockWithDoneHookBlock( JFFAsyncOperation loader_
                                               , JFFDidFinishAsyncOperationHook done_callback_hook_ );
