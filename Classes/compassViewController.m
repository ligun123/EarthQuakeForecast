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
#import "InfoViewController.h"

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
    waveView = [[EarthWaveView alloc] initWithFrame:CGRectMake(0, 30, 320, 150)];
    [self.view addSubview:waveView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapInView:)];
    [self.view addGestureRecognizer:tap];
    [tap autorelease];
    
    waringLabel.text = NSLocalizedString(@"EarthQuake", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layout];
}

- (void)layout
{
    if ([[UIScreen mainScreen] bounds].size.height > 500) {
        backgroundView.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
        waringMaskImage.frame = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height);
    }
}

- (IBAction)btnInfoTap:(id)sender
{
    InfoViewController *info = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
    info.modalPresentationStyle = UIModalPresentationFullScreen;
    info.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:info animated:YES];
    [info autorelease];
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
