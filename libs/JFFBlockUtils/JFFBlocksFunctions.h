#import <JFFBlockUtils/JFFBlocksDefinitions.h>

@class NSArray;

JFFAsyncDataLoader loaderBlockWithBlocksSequence( JFFAsyncDataLoader first_loader_
                                                , JFFAsyncDataLoader second_loader_, ... );
JFFAsyncDataLoader loaderBlockWithBlocksSequenceArray( NSArray* blocks_ );

JFFAsyncDataLoader loaderBlockWithBlocksTrySequence( JFFAsyncDataLoader first_loader_
                                                   , JFFAsyncDataLoader second_loader_, ... );

JFFAsyncDataLoader loaderBlockWithBlocksGroup( JFFAsyncDataLoader first_loader_
                                             , JFFAsyncDataLoader second_loader_, ... );
JFFAsyncDataLoader loaderBlockWithBlocksGroupArray( NSArray* blocks_ );

JFFAsyncDataLoader loaderBlockFailOnFirstErrorWithBlocksGroup( JFFAsyncDataLoader first_loader_
                                                             , JFFAsyncDataLoader second_loader_, ... );
JFFAsyncDataLoader loaderBlockFailOnFirstErrorWithBlocksGroupArray( NSArray* blocks_ );

JFFAsyncDataLoader loaderBlockWithDoneCallbackBlock( JFFAsyncDataLoader loader_
                                                   , JFFDidFinishAsyncOperationHandler done_callback_block_ );
JFFAsyncDataLoader loaderBlockWithDoneHookBlock( JFFAsyncDataLoader loader_
                                               , JFFDidFinishAsyncOperationHook done_callback_hook_ );
