#import <Foundation/Foundation.h>

@class JFFScheduler;

@interface NSObject (Scheduler)

-(void)performSelector:( SEL )selector_
          timeInterval:( NSTimeInterval )time_interval_
              userInfo:( id )user_info_
               repeats:( BOOL )repeats_;

-(void)performSelector:( SEL )selector_
          timeInterval:( NSTimeInterval )time_interval_
              userInfo:( id )user_info_ 
               repeats:( BOOL )repeats_
             scheduler:( JFFScheduler* )scheduler_;

@end
