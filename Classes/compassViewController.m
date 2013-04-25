//
//  compassViewController.m
//  Teslameter
//
//  Created by Kira on 4/22/13.
//
//

#import "compassViewController.h"
#import "EarthWaveView.h"
#import <QuartzCore/QuartzCore.h>

@implementation compassViewController

@synthesize locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [waveView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    waveView = [[EarthWaveView alloc] initWithFrame:CGRectMake(0, 50, 320, 200)];
    [self.view addSubview:waveView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInView:)];
    [self.view addGestureRecognizer:tap];
    [tap autorelease];
    
    waringLabel.text = NSLocalizedString(@"EarthQuake", nil);
}

- (void)tapInView:(UIGestureRecognizer *)gesture
{
    [waringMaskImage.layer removeAnimationForKey:@"flash"];
    waringMaskImage.hidden = YES;
    waringLabel.hidden = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - EarthQuakeManagerDelegate

- (void)EQManager:(EarthQuakeManager *)manager updatingHeading:(CLHeading *)heading
{
    [waveView setNeedsDisplay];
    
    compassImage.transform = CGAffineTransformIdentity;
    CGAffineTransform transform = CGAffineTransformMakeRotation(-1 * M_PI*heading.magneticHeading/180.0);
    compassImage.transform = transform;
}

- (void)EQManager:(EarthQuakeManager *)manager EQLevel:(NSInteger)level
{//警报动画
    if (waringMaskImage.hidden == YES) {
        waringLabel.hidden = NO;
        waringMaskImage.hidden = NO;
        CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue=[NSNumber numberWithFloat:1.0];
        animation.toValue=[NSNumber numberWithFloat:0.2];
        animation.autoreverses=YES;
        animation.duration=0.5;
        animation.repeatCount=FLT_MAX;
        animation.removedOnCompletion=NO;
        animation.fillMode=kCAFillModeForwards;
        [waringMaskImage.layer addAnimation:animation forKey:@"flash"];
    }
}

@end
