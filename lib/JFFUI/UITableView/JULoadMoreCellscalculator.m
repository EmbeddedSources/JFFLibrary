#import "JULoadMoreCellscalculator.h"

@implementation JULoadMoreCellscalculator

@synthesize currentCount = _current_count;
@synthesize pageSize = _page_size;
@synthesize totalElementsCount = _total_elements_count;

@dynamic hasNoElements;
@dynamic allElementsLoaded;
@dynamic loadMoreIndexPath;

static const NSUInteger RIUndefinedElementsCount = NSUIntegerMax;

-(BOOL)hasNoElements
{
   return ( self.totalElementsCount == 0  ) || ( self.totalElementsCount == RIUndefinedElementsCount );
}

-(BOOL)allElementsLoaded
{
   return ( self.currentCount >=  self.totalElementsCount );
}

-(NSIndexPath*)loadMoreIndexPath
{
   return [ NSIndexPath indexPathForRow: self.currentCount
                              inSection: 0 ];
}

-(BOOL)noNeedToLoadElementAtIndexPath:( NSIndexPath* )index_path_
{
   return ( index_path_.row < self.currentCount );
}

-(NSArray*)prepareIndexPathEntriesForBottomCells:(NSUInteger)cells_count_
{
   if ( 0 == cells_count_ )
   {
      return nil;
   }
   
   NSMutableArray* index_paths_ = [ NSMutableArray arrayWithCapacity: cells_count_ ];
   
   NSUInteger new_row_index_ = self.currentCount + 1; //right after LoadMore button.
   for ( int i = 0; i < cells_count_; ++i, ++new_row_index_ )
   {
      NSIndexPath* new_item_ = [ NSIndexPath indexPathForRow: new_row_index_
                                                   inSection: 0 ];
      
      [ index_paths_ addObject: new_item_ ];
   }
   
   return index_paths_;
}

-(NSUInteger)suggestElementsToAddCountForIndexPath:( NSIndexPath* )index_path_
                                   overflowOccured:( BOOL* )out_is_overflow_
{
   NSAssert( out_is_overflow_, @"is_overflow_ is not optional" );
   *out_is_overflow_ = NO;
   
   // if all loaded
   if ( self.hasNoElements )
   {
      return 0;
   }
   if ( self.allElementsLoaded )
   {
      *out_is_overflow_ = YES;
      return 0;
   }
   if ( [ self noNeedToLoadElementAtIndexPath: index_path_ ] )
   {
      return 0;
   }
   
   static const NSUInteger load_more_placeholder_size_ = 1;
   NSUInteger rest_of_the_pages_ = self.totalElementsCount - self.currentCount;
   BOOL is_paging_disabled_ = ( self.pageSize == 0 );   
   if ( is_paging_disabled_ )
   {
      return rest_of_the_pages_ - load_more_placeholder_size_;
   }
   
   float items_count_for_index_path_ = 1 + index_path_.row;
   NSUInteger pages_expected_ = ceil( items_count_for_index_path_ / self.pageSize );
   NSUInteger elements_expected_ = pages_expected_ * self.pageSize;
   
   //check if paging disabled
   BOOL is_overflow_ = ( elements_expected_ >= self.totalElementsCount );
   if ( is_overflow_ )
   {
      *out_is_overflow_ = YES;
      return rest_of_the_pages_ - load_more_placeholder_size_;
   }
   
   return elements_expected_ - self.currentCount;
}

@end
