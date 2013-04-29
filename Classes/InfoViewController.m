//
//  InfoViewController.m
//  Teslameter
//
//  Created by HalloWorld on 13-4-29.
//
//

#import "InfoViewController.h"
#import "EarthQuakeManager.h"

@implementation InfoViewController

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
    mgLabel = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    mgLabel.text = NSLocalizedString(@"Sensitivity", nil);
    mgSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kBoolMGSwitchState];
    
    [btnBack setTitle:NSLocalizedString(@"btnBack", nil) forState:UIControlStateNormal];
    [btnBack setTitleColor:[UIColor darkGrayColor] forState:UIControlStateSelected];
    
    [btnEmailFriends setTitle:NSLocalizedString(@"btnEmailFriends", nil) forState:UIControlStateNormal];
    
    [btnEmailDev setTitle:NSLocalizedString(@"btnEmailDev", nil) forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)mgSwitchTap:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:((UISwitch *)sender).on forKey:kBoolMGSwitchState];
}

- (IBAction)btnBackTap:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)btnEmailFriends:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailview = [[MFMailComposeViewController alloc] init];
        mailview.mailComposeDelegate = self;
        [mailview setSubject:NSLocalizedString(@"recommend", nil)];
        [mailview setMessageBody:NSLocalizedString(@"recommendBody", nil) isHTML:NO];
        [self presentModalViewController:mailview animated:YES];
        [mailview autorelease];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissModalViewControllerAnimated:YES];
}
@end
