//
//  EarthQuakeManager.m
//  Teslameter
//
//  Created by Kira on 4/23/13.
//
//

#import "EarthQuakeManager.h"


@implementation EarthQuakeManager
@synthesize locationManager;
@synthesize delegate;
@synthesize isBackground, hasPushNotification;
@synthesize oldMagnetometerData;

static EarthQuakeManager *EarthQuakeInterface = nil;

+ (id)shareInterface
{
    if (EarthQuakeInterface == nil) {
        EarthQuakeInterface = [[self alloc] init];
    }
    return EarthQuakeInterface;
}

- (id)init
{
    self = [super init];
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        if ([CLLocationManager headingAvailable]) {
            //设置精度
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            //设置滤波器不工作
            self.locationManager.headingFilter = kCLHeadingFilterNone;
            //开始更新
            [self.locationManager startUpdatingHeading];
            [self.locationManager startUpdatingLocation];
            
            headChangeArray = [[NSMutableArray alloc] initWithCapacity:320];
            countAdded = 0;
            
            //sys sound
            NSString *path = [[NSBundle mainBundle] pathForResource:@"alert2" ofType:@"wav"];
            //Get a URL for the sound file
            NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
            //Use audio sevices to create the sound
            AudioServicesCreateSystemSoundID((CFURLRef)filePath, &soundID);
            
            hasDisturb = YES;
            isBackground = NO;
            hasPushNotification = NO;
            //加速计
            [self startMotionCheck];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CannotWork" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    return self;
}

- (CMMotionManager *)CmManager
{
    if (cmManager == nil) {
        cmManager = [[CMMotionManager alloc] init];
        if ([cmManager isDeviceMotionAvailable] == YES) {
            [cmManager setDeviceMotionUpdateInterval:CMMotionUpdateInterval];
        }
    }
    return cmManager;
}

- (NSOperationQueue *)BgQueue
{
    if (bgQueue == nil) {
        bgQueue = [[NSOperationQueue alloc] init];
    }
    return bgQueue;
}



- (void)dealloc
{
    [cmManager release];
    [headChangeArray release];
    self.delegate = nil;
    self.locationManager = nil;
    [super dealloc];
}

- (NSMutableArray *)HeadChangeArray
{
    return headChangeArray;
}

- (void)earthQuakeAlertLevel:(NSInteger)level
{
    //Use audio services to play the sound
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        AudioServicesPlayAlertSound(soundID);
    });
    if (delegate && [delegate respondsToSelector:@selector(EQManager:EQLevel:)]) {
        [delegate EQManager:self EQLevel:level];
    }
    if (isBackground && !hasPushNotification) {
        UILocalNotification *notification=[[UILocalNotification alloc] init];
        if (notification != nil) {
            NSLog(@">> support local notification");
            notification.fireDate = [NSDate date];
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.alertBody = NSLocalizedString(@"EarthQuakeNoti", nil);
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            hasPushNotification = YES;
        }
    }
}

- (void)startMotionCheck
{
    [[self CmManager] startDeviceMotionUpdatesToQueue:[self BgQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        
        if (fabs(motion.userAcceleration.x) > floatDisturbKey ||
            fabs(motion.userAcceleration.y) > floatDisturbKey ||
            fabs(motion.userAcceleration.z) > floatDisturbKey ||
            fabs(motion.rotationRate.z) > floatDisturbKey ||
            fabs(motion.rotationRate.y) > floatDisturbKey ||
            fabs(motion.rotationRate.x) > floatDisturbKey) {
            //手机处于晃动状态或者转动状态，不检测
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                hasDisturb = YES;
            }];
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                hasDisturb = NO;
            }];
        }
    }];
    
    
    [[self CmManager] setMagnetometerUpdateInterval:1/10.0];
    [[self CmManager] startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
        [self addNewMagnetometer:magnetometerData];
    }];
}

- (void)addNewMagnetometer:(CMMagnetometerData *)magneticData
{
    if ([headChangeArray count] >= MaxHeadPoints) {
        [headChangeArray removeObjectAtIndex:0];
    }
    float change = [self averageChange:magneticData];
    [headChangeArray addObject:[NSNumber numberWithFloat:change]];
    self.oldMagnetometerData = magneticData;
    if (hasDisturb) {
        countAdded = -1;
        return;
    }
    if (fabs(change) >= 10 && countAdded < 0) {
        countAdded = 0;
    }
    if (countAdded < MaxUsedCount && countAdded >= 0) {
        countAdded ++;
    }
    
    if (countAdded == MaxUsedCount) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            countAdded = MaxUsedCount;
            NSUInteger sum = 0;
            NSInteger count = [headChangeArray count];
            for (int i = 1; i < MaxUsedCount; i ++) {
                sum += (NSUInteger)fabs([[headChangeArray objectAtIndex:count -i] floatValue]);
            }
            NSInteger level = sum / MaxUsedCount;
            NSInteger key = ([[NSUserDefaults standardUserDefaults] boolForKey:kBoolMGSwitchState]) ? averageQuakeKeyHight : averageQuakeKey;
            if (level >= key) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[EarthQuakeManager shareInterface] earthQuakeAlertLevel:level];
                });
            }
            NSLog(@"%s -> level : %d", __FUNCTION__, level);
            countAdded = -1;
        });
    }
}

- (float)averageChange:(CMMagnetometerData *)magneticData
{
    float ax = fabsf(oldMagnetometerData.magneticField.x - magneticData.magneticField.x);
    float ay = fabsf(oldMagnetometerData.magneticField.y - magneticData.magneticField.y);
    float az = fabsf(oldMagnetometerData.magneticField.z - magneticData.magneticField.z);
    return sqrtf(ax*ax + ay*ay + az*az)/ 3.0;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (delegate && [delegate respondsToSelector:@selector(EQManager:updatingHeading:)]) {
        [delegate EQManager:self updatingHeading:newHeading];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
}


#pragma mark - UIAccelerometerDelegate

@end

