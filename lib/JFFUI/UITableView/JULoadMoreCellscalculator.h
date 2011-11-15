#import <Foundation/Foundation.h>
@class UITableView;


@protocol JUTableViewHolder <NSObject>

@required
   @property ( nonatomic, retain, readonly  ) UITableView* tableView   ;
   @property ( nonatomic, assign            ) NSInteger   currentCount;

@end

@class UITableView;

@protocol JUTableViewHolder <NSObject>

@required
   @property ( nonatomic, retain, readonly ) UITableView* tableView  ;
   @property ( nonatomic, assign           ) NSInteger   currentCount;

@end

@class UITableView;

@protocol JUTableViewHolder <NSObject>

@required
   @property ( nonatomic, retain, readonly ) UITableView* tableView  ;
   @property ( nonatomic, assign           ) NSInteger   currentCount;

@end

@class UITableView;

@protocol JUTableViewHolder <NSObject>

@required
   @property ( nonatomic, retain, readonly ) UITableView* tableView  ;
   @property ( nonatomic, assign           ) NSInteger   currentCount;

@end

@interface JULoadMoreCellscalculator : NSObject

@property ( nonatomic, assign ) NSUInteger currentCount;
@property ( nonatomic, assign ) NSUInteger pageSize;
@property ( nonatomic, assign ) NSUInteger totalElementsCount;

@property ( nonatomic, assign, readonly ) BOOL       isPagingDisabled;
@property ( nonatomic, assign, readonly ) BOOL       isPagingEnabled ;
@property ( nonatomic, assign, readonly ) NSUInteger numberOfRows    ;

-(NSArray*)prepareIndexPathEntriesForBottomCells:( NSUInteger )cells_count_;
-(NSUInteger)suggestElementsToAddCountForIndexPath:( NSIndexPath* )index_path_
                                   overflowOccured:( BOOL* )is_overflow_;
-(NSUInteger)suggestElementsToAddCountForIndex:( NSUInteger )index_
                               overflowOccured:( BOOL* )out_is_overflow_;



@property ( nonatomic, assign, readonly ) BOOL hasNoElements;
@property ( nonatomic, assign, readonly ) BOOL allElementsLoaded;
@property ( nonatomic, retain, readonly ) NSIndexPath* loadMoreIndexPath;
-(BOOL)isLoadMoreIndexPath:( NSIndexPath* )index_path_;

<<<<<<< HEAD
-(BOOL)isLoadMoreIndexPath:( NSIndexPath* )index_path_;
-(NSInteger)currentCountToStartWith:( NSInteger )total_elements_count_;
=======
-(BOOL)noNeedToLoadElementAtIndexPath:( NSIndexPath* )index_path_;
-(NSInteger)currentCountToStartWith:( NSInteger )total_elements_count_;

>>>>>>> b1faa8014a7c6e92b281ea30fb3eff12a0adb963
+(NSArray*)defaultUpdateScopeForIndex:( NSUInteger )index_;


-(void)autoLoadingScrollTableView:( id<JUTableViewHolder> )table_view_holder_
                 toRowAtIndexPath:( NSIndexPath* )index_path_ 
                 atScrollPosition:( UITableViewScrollPosition )scroll_position_ 
                         animated:( BOOL )animated_;

@end
