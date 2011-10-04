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
   if ( 0 == size_diff_ )
   {
      return;
   }

   NSUInteger removal_location_ = new_size_;
   NSRange removal_range_ = NSMakeRange( removal_location_, size_diff_ );
   
   [ self removeObjectsInRange: removal_range_ ];
}

@end
