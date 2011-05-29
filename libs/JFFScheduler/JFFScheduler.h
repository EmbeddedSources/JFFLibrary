#import <Foundation/Foundation.h>

typedef void (^JFFCancelScheduledBlock) ( void );
typedef void (^JFFScheduledBlock) ( JFFCancelScheduledBlock cancel_ );

@interface JFFScheduler : NSObject
{
@private
   NSMutableArray* _cancel_blocks;
}

+(id)scheduler;

+(id)sharedScheduler;

-(JFFCancelScheduledBlock)addBlock:( JFFScheduledBlock )block_ duration:( NSTimeInterval )duration_;

-(void)cancelAllScheduledOperations;

@end
