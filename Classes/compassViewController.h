//
//  compassViewController.h
//  Teslameter
//
//  Created by Kira on 4/22/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "EarthWaveView.h"
#import "EarthQuakeManager.h"

@interface compassViewController : UIViewController <EarthQuakeManagerProtocol>
{
    EarthWaveView *waveView;
    IBOutlet UIImageView *compassImage;
    IBOutlet UIImageView *waringMaskImage;
    IBOutlet UIImageView *backgroundView;
    IBOutlet UILabel *waringLabel;
}

@property (nonatomic, retain)CLLocationManager *locationManager;

- (IBAction)btnInfoTap:(id)sender;

- (void)layout;

@end
