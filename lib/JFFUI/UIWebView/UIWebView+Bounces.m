#import "UIWebView+Bounces.h"

#import <JFFUtils/NSArray/NSArray+BlocksAdditions.h>

@interface UIWebView (BouncesInternal)

@property ( nonatomic, retain, readonly ) UIScrollView* scrollView;

@end

@implementation UIWebView (Bounces)

-(UIScrollView*)scrollView
{
   return [ self.subviews firstMatch: ^BOOL( id subview_ )
   {
      return [ [ subview_ class ] isSubclassOfClass: [ UIScrollView class ] ];
   } ];
}

-(BOOL)bounces
{
   return self.scrollView.bounces;
}

-(void)setBounces:( BOOL )bounces_
{
   self.scrollView.bounces = bounces_;
}

@end
