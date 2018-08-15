//
//  ColorSlider.m
//
//  Created by Orangebananaspy on 2018-08-07.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import "OBSUtilities/ColorSlider.h"

@interface ColorSlider()
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic) CGRect backgroundFrame;
@property (nonatomic) SliderType type;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@end

@implementation ColorSlider
- (ColorSlider *)initWithFrame:(CGRect)frame withType:(SliderType)sliderType {
  self = [super initWithFrame:frame];
  if(self) {
    self.type = sliderType;
    
    self.backgroundFrame = CGRectMake(2.5, 0, self.frame.size.width - 5, self.frame.size.height);
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.backgroundFrame];
    self.backgroundView.center = self.center;
    self.backgroundView.layer.cornerRadius = frame.size.height / 2.0f;
    self.backgroundView.layer.masksToBounds = YES;
    [self addSubview:self.backgroundView];
    
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.backgroundView.bounds;
    self.gradientLayer.startPoint = CGPointMake(0.0, 0.5);
    self.gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    [self.backgroundView.layer insertSublayer:self.gradientLayer atIndex:0];
    
    self.slider = [[UISlider alloc] initWithFrame:self.bounds];
    self.slider.center = self.center;
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    self.slider.minimumTrackTintColor = [UIColor clearColor];
    [self addSubview:self.slider];
  }
  return self;
}

- (void)setTag:(NSInteger)tag {
  [super setTag:tag];
  
  self.slider.tag = tag;
}

- (void)addTarget:(nullable id)target action:(nonnull SEL)action forControlEvents:(UIControlEvents)controlEvents {
  [self.slider addTarget:target action:action forControlEvents:controlEvents];
}

- (CGFloat)getValue {
  return self.slider.value;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  self.backgroundView.frame = self.backgroundFrame;
  self.gradientLayer.frame = self.backgroundView.bounds;
  self.slider.frame = self.bounds;
}

- (void)setStartColor:(UIColor *)startColor andEndColor:(UIColor *)endColor {
  NSArray *colors = @[(id)startColor.CGColor, (id)endColor.CGColor];
  self.gradientLayer.colors = colors;
}

- (void)minMaxOfColor:(UIColor *)color {
  const CGFloat *components = CGColorGetComponents(color.CGColor);
  CGFloat red = components[0];
  CGFloat green = components[1];
  CGFloat blue = components[2];
  CGFloat alpha = components[3];
  
  UIColor *minColor;
  UIColor *maxColor;
  
  if(self.type == kRed) {
    minColor = [UIColor colorWithRed:0.0f green:green blue:blue alpha:alpha];
    maxColor = [UIColor colorWithRed:1.0f green:green blue:blue alpha:alpha];
    self.slider.value = red;
  } else if(self.type == kGreen) {
    minColor = [UIColor colorWithRed:red green:0.0f blue:blue alpha:alpha];
    maxColor = [UIColor colorWithRed:red green:1.0f blue:blue alpha:alpha];
    self.slider.value = green;
  } else if(self.type == kBlue) {
    minColor = [UIColor colorWithRed:red green:green blue:0.0f alpha:alpha];
    maxColor = [UIColor colorWithRed:red green:green blue:1.0f alpha:alpha];
    self.slider.value = blue;
  } else if(self.type == kAlpha) {
    minColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.0f];
    maxColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
    self.slider.value = alpha;
  } else {
    NSLog(@"Error no type declared.");
  }

  [self setStartColor:minColor andEndColor:maxColor];
}
@end
