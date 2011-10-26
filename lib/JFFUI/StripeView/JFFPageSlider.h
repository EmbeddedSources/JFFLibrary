#import <UIKit/UIKit.h>

@protocol JFFPageSliderDelegate;

@interface JFFPageSlider : UIView

@property ( nonatomic, strong, readonly ) UIScrollView* scrollView;

@property ( nonatomic, assign, readonly ) NSInteger activeIndex;
@property ( nonatomic, assign, readonly ) NSInteger firstIndex;
@property ( nonatomic, assign, readonly ) NSInteger lastIndex;

@property ( nonatomic, unsafe_unretained ) IBOutlet id< JFFPageSliderDelegate > delegate;

-(id)initWithFrame:( CGRect )frame_
          delegate:( id< JFFPageSliderDelegate > )delegate_;

-(void)reloadData;

-(UIView*)elementAtIndex:( NSInteger )index_;

-(NSArray*)visibleElements;

-(void)slideForward;
-(void)slideBackward;

-(void)pushFrontElement;
-(void)pushBackElement;

-(void)slideToIndex:( NSInteger )index_ animated:(BOOL)animated_;
-(void)slideToIndex:( NSInteger )index_;

@end
