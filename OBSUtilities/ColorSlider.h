//
//  ColorSlider.h
//
//  Created by Orangebananaspy on 2018-08-07.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef ColorSlider_h
#define ColorSlider_h

typedef enum SliderType : NSUInteger {
  kRed,
  kGreen,
  kBlue,
  kAlpha
} SliderType;

@interface ColorSlider : UIView
/*
 The current slider value.
 */
@property (readonly, nonatomic, getter=getValue) CGFloat value;

/*
 Initializer that requires the type of slider it is representing.
 */
- (ColorSlider *)initWithFrame:(CGRect)frame withType:(SliderType)sliderType;

/*
 Sets the minimum color and the maximum color of the slider. It specifically
 the gradient of the slider where minimum is the left side, and maximum is the right side.
 */
- (void)minMaxOfColor:(UIColor *)color;
- (void)addTarget:(nullable id)target action:(nonnull SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end
#endif /* ColorSlider_h */
