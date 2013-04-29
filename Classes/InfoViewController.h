//
//  InfoViewController.h
//  Teslameter
//
//  Created by HalloWorld on 13-4-29.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface InfoViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    IBOutlet UILabel *mgLabel;
    IBOutlet UISwitch *mgSwitch;
    
    IBOutlet UIButton *btnBack;
    
    IBOutlet UIButton *btnEmailFriends;
    
    IBOutlet UIButton *btnEmailDev;
}
- (IBAction)mgSwitchTap:(id)sender;

- (IBAction)btnBackTap:(id)sender;

- (IBAction)btnEmailFriends:(id)sender;

@end
