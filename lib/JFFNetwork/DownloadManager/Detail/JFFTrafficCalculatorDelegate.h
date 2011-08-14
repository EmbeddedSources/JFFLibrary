#import <UIKit/UIKit.h>

@class JFFTrafficCalculator;

@protocol JFFTrafficCalculatorDelegate < NSObject >

-(void)trafficCalculator:( JFFTrafficCalculator* )traffic_calculator_
  didChangeDownloadSpeed:( float )speed_;

@end
