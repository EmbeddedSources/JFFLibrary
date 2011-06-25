#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

JFFAsyncOperation asyncOperationWithSyncOperation( JFFSyncOperation load_data_block_ );

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progress_load_data_block_ );
