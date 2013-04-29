//
//  EarthWaveView.m
//  Teslameter
//
//  Created by Kira on 4/22/13.
//
//

#import "EarthWaveView.h"
#import <QuartzCore/QuartzCore.h>
#import "EarthQuakeManager.h"


@implementation EarthWaveView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSMutableArray *array = [[EarthQuakeManager shareInterface] HeadChangeArray];
    float height = self.frame.size.height;
    [[UIColor redColor] set];
    if ([array count] > 0) {
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 0, height - [[array objectAtIndex:0] floatValue]);
    }
    
    for (int i = 0; i < [array count]; i ++) {
        float f = [[array objectAtIndex:i] floatValue];
        CGPoint p = CGPointMake(i*2,height - f);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), p.x, p.y);
    }
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
}


@end
