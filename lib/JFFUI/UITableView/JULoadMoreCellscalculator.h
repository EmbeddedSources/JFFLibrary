#import <Foundation/Foundation.h>

@interface JULoadMoreCellscalculator : NSObject

@property ( nonatomic, assign ) NSUInteger currentCount;
@property ( nonatomic, assign ) NSUInteger pageSize;
@property ( nonatomic, assign ) NSUInteger totalElementsCount;

-(NSArray*)prepareIndexPathEntriesForBottomCells:( NSUInteger )cells_count_;
-(NSUInteger)suggestElementsToAddCountForIndexPath:( NSIndexPath* )index_path_
                                   overflowOccured:( BOOL* )is_overflow_;

@property ( nonatomic, assign, readonly ) BOOL hasNoElements;
@property ( nonatomic, assign, readonly ) BOOL allElementsLoaded;
@property ( nonatomic, retain, readonly ) NSIndexPath* loadMoreIndexPath;

-(BOOL)noNeedToLoadElementAtIndexPath:( NSIndexPath* )index_path_;

@end
