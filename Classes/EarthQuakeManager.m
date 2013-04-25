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
@synthesize oldHeading;

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
    NSLog(@"%s -> ", __FUNCTION__);
    //Use audio services to play the sound
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        AudioServicesPlaySystemSound(soundID);
    });
    if (delegate && [delegate respondsToSelector:@selector(EQManager:EQLevel:)]) {
        [delegate EQManager:self EQLevel:level];
    }
}

- (void)startMotionCheck
{
    [[self CmManager] startDeviceMotionUpdatesToQueue:[self BgQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        if (fabs(motion.userAcceleration.x) > 0.1 || fabs(motion.userAcceleration.y) > 0.1 || fabs(motion.userAcceleration.z) > 0.1
            || fabs(motion.rotationRate.z) > 0.1 || fabs(motion.rotationRate.y) > 0.1 || fabs(motion.rotationRate.x) > 0.1) {
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
}

- (void)addNewHeading:(CLHeading *)heading
{
    if ([headChangeArray count] >= MaxHeadPoints) {
        [headChangeArray removeObjectAtIndex:0];
    }
    float change = oldHeading.magneticHeading - heading.magneticHeading;
    self.oldHeading = heading;
    [headChangeArray addObject:[NSNumber numberWithFloat:change]];
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
            if (level >= averageQuakeKey) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[EarthQuakeManager shareInterface] earthQuakeAlertLevel:level];
                });
            } else {
                NSLog(@"%s -> Safe : %d", __FUNCTION__, level);
            }
            countAdded = -1;
        });
    }
    
}


-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [self addNewHeading:newHeading];
    if (delegate && [delegate respondsToSelector:@selector(EQManager:updatingHeading:)]) {
        [delegate EQManager:self updatingHeading:newHeading];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
}


#pragma mark - UIAccelerometerDelegate

@end
