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
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 0, height/2);
    for (int i = 0; i < [array count]; i ++) {
        float f = [[array objectAtIndex:i] floatValue];
        CGPoint p = CGPointMake(i,f+height/2);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), p.x, p.y);
    }
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
}


@end
