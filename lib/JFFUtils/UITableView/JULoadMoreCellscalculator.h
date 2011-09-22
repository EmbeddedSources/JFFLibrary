#import <Foundation/Foundation.h>

@interface JULoadMoreCellscalculator : NSObject

@property ( nonatomic, assign ) NSUInteger currentCount;
@property ( nonatomic, assign ) NSUInteger pageSize;
@property ( nonatomic, assign ) NSUInteger totalClipsCount;

-(NSArray*)prepareIndexPathEntriesForBottomCells:(NSUInteger)cells_count_;
-(NSUInteger)suggestClipsToAddCountForIndexPath:( NSIndexPath* )index_path_
                                overflowOccured:( BOOL* )is_overflow_;

@property ( nonatomic, assign, readonly ) BOOL hasNoClips;
@property ( nonatomic, assign, readonly ) BOOL allClipsLoaded;
@property ( nonatomic, retain, readonly ) NSIndexPath* loadMoreIndexPath;

-(BOOL)noNeedToLoadClipAtIndexPath:( NSIndexPath* )index_path_;

@end
