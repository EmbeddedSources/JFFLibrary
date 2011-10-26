#import <Foundation/Foundation.h>

@class JFFPageSlider;

@protocol JFFPageSliderDelegate < NSObject >

@required
-(NSInteger)numberOfElementsInStripeView:( JFFPageSlider* )pageSlider_;

-(UIView*)stripeView:( JFFPageSlider* )pageSlider_
      elementAtIndex:( NSInteger )index_;

@end
