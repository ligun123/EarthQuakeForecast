//
//  EarthQuakeManager.h
//  Teslameter
//
//  Created by Kira on 4/23/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMotion/CoreMotion.h>

#define averageQuakeKey 1
#define MaxHeadPoints 320
#define MaxUsedCount 180
#define CMMotionUpdateInterval 1.0/10

@class EarthQuakeManager;

@protocol EarthQuakeManagerProtocol <NSObject>

- (void)EQManager:(EarthQuakeManager *)manager updatingHeading:(CLHeading *)heading;
- (void)EQManager:(EarthQuakeManager *)manager EQLevel:(NSInteger)level;

@end






@interface EarthQuakeManager : NSObject <CLLocationManagerDelegate>
{
    NSMutableArray *headChangeArray;
    __block NSInteger countAdded;
    SystemSoundID soundID;
    CMMotionManager *cmManager;
    NSOperationQueue *bgQueue;
    BOOL hasDisturb;
}

@property (nonatomic, assign)id <EarthQuakeManagerProtocol>delegate;
@property (nonatomic, retain)CLLocationManager *locationManager;
@property (nonatomic, retain)CLHeading *oldHeading;

+ (id)shareInterface;
- (NSMutableArray *)HeadChangeArray;
- (void)addNewHeading:(CLHeading *)heading;

- (void)startMotionCheck;
- (CMMotionManager *)CmManager;
- (NSOperationQueue *)BgQueue;

@end
