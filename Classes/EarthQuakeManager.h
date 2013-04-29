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

#define averageQuakeKey 3
#define averageQuakeKeyHight 1
#define MaxHeadPoints 160
#define MaxUsedCount 50
#define CMMotionUpdateInterval 1.0/10
#define kBoolMGSwitchState @"kBoolMGSwitchState"

#define floatDisturbKey 0.2
#define floatDisturbKeyHight 0.2

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
    
    BOOL isBackground;
    BOOL hasPushNotification;
}

@property (nonatomic, assign)id <EarthQuakeManagerProtocol>delegate;
@property (nonatomic, retain)CLLocationManager *locationManager;
@property (nonatomic, assign)BOOL isBackground;
@property (nonatomic, assign)BOOL hasPushNotification;
@property (nonatomic, retain)CMMagnetometerData *oldMagnetometerData;

+ (id)shareInterface;

//原始磁场数据变化
- (NSMutableArray *)HeadChangeArray;
- (void)addNewMagnetometer:(CMMagnetometerData *)magneticData;
- (float)averageChange:(CMMagnetometerData *)magneticData;

- (void)startMotionCheck;
- (CMMotionManager *)CmManager;
- (NSOperationQueue *)BgQueue;

@end
