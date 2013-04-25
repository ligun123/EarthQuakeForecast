//
//  compassViewController.m
//  Teslameter
//
//  Created by Kira on 4/22/13.
//
//

#import "compassViewController.h"
#import "EarthWaveView.h"

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
}

- (void)EQManager:(EarthQuakeManager *)manager EQLevel:(NSInteger)level
{//警报动画
}

@end
