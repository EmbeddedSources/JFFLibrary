#import "NSMutableArray+ChangeCount.h"


@implementation NSMutableArray ( ChangeCount )

-(void)shrinkToSize:( NSUInteger )new_size_
{
   NSUInteger count_ = [ self count ];
   
   if ( count_ <= new_size_ )
   {
      //The size already fits
      return;
   }


   NSUInteger size_diff_ = count_ - new_size_;
   for ( NSUInteger i_ = 0; i_ < size_diff_; ++i_ )
   {
      [ self removeLastObject ];
   }
}

@end
