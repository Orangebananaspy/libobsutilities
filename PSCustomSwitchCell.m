//
//  PSCustomSwitchCell.m
//
//  Created by Orangebananaspy on 2018-08-08.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import "OBSUtilities/PSCustomSwitchCell.h"
#import "OBSUtilities/OBSUtilities.h"

#define tweakPreferencePath @"/var/mobile/Library/Preferences/"

@interface PSCustomSwitchCell ()
@property (nonatomic, weak) PSTweakSettings *settings;
@property (nonatomic, strong) UISwitch *cellSwitch;
@property (nonatomic, strong) UIView *switchBackground;
@property (nonatomic, strong) CAGradientLayer *switchGradientLayer;
@property (nonatomic, strong) NSArray *onGradientColors;
@property (nonatomic, strong) NSArray *offGradientColors;
@end

@implementation PSCustomSwitchCell
- (instancetype)initWithStyle:(int)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
  self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];
  
  if(self) {
    self.settings = [PSTweakSettings instanceWithName:[specifier.properties[@"preferenceName"] copy] andUser:[specifier.properties[@"preferenceName"] copy]];
    
    self.specifier = specifier;
    NSString *keyValue = [specifier.properties[@"key"] copy];
    NSString *keyLabel = [specifier.properties[@"keyLabel"] copy];
    NSString *keyDescription = [specifier.properties[@"description"] copy];
    
    bool defaultBool;
    if(![self.settings getSettingsForKey:keyValue]) {
      defaultBool = [[specifier.properties[@"default"] copy] boolValue];
    } else {
      defaultBool = [[self.settings getSettingsForKey:keyValue] boolValue];
    }
    
    self.textLabel.text = keyLabel;
    self.detailTextLabel.text = keyDescription;
    
    self.cellSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.cellSwitch setOn:defaultBool animated:NO];
    [self.cellSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    self.cellSwitch.onTintColor = [UIColor clearColor];
    self.cellSwitch.tintColor = [UIColor clearColor];
    
    self.switchBackground = [[UIView alloc] initWithFrame:self.cellSwitch.bounds];
    self.switchBackground.layer.cornerRadius = self.cellSwitch.bounds.size.height / 2.0f;
    self.switchBackground.layer.masksToBounds = YES;
    self.switchBackground.clipsToBounds = YES;
    [self.cellSwitch insertSubview:self.switchBackground atIndex:0];
    
    self.accessoryView = self.cellSwitch;
    
    self.onGradientColors = @[(id)[OBSUtilities colorFromHexString:@"2CB5E8"].CGColor, (id)[OBSUtilities colorFromHexString:@"1FC8DB"].CGColor, (id)[OBSUtilities colorFromHexString:@"0FB8AD"].CGColor];
    self.offGradientColors = @[(id)[OBSUtilities colorFromHexString:@"#FF416C"].CGColor, (id)[OBSUtilities colorFromHexString:@"#FF4B2B"].CGColor, (id)[OBSUtilities colorFromHexString:@"#FF4B2B"].CGColor];
    
    self.switchGradientLayer = [CAGradientLayer layer];
    self.switchGradientLayer.frame = self.switchBackground.bounds;
    self.switchGradientLayer.colors = self.cellSwitch.isOn ? self.onGradientColors : self.offGradientColors;
    [self.switchBackground.layer insertSublayer:self.switchGradientLayer atIndex:0];
    
    float x = -141.0f / 360.0f;
    float a = pow(sinf((2*M_PI*((x+0.75)/2))),2);
    float b = pow(sinf((2*M_PI*((x+0.0)/2))),2);
    float c = pow(sinf((2*M_PI*((x+0.25)/2))),2);
    float d = pow(sinf((2*M_PI*((x+0.5)/2))),2);
    
    [self.switchGradientLayer setStartPoint:CGPointMake(a, b)];
    [self.switchGradientLayer setEndPoint:CGPointMake(c, d)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionWasEnabled) name:keyValue object:nil];
  }
  
  return self;
}

- (void)switchChanged {
  [self updatePreferences:self.cellSwitch.isOn];
  
  if(!self.cellSwitch.isOn) {
    CABasicAnimation *animateLayer = [CABasicAnimation animationWithKeyPath:@"colors"];
    animateLayer.toValue = self.offGradientColors;
    animateLayer.duration = 0.2;
    animateLayer.removedOnCompletion = NO;
    animateLayer.fillMode = kCAFillModeForwards;
    animateLayer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.switchGradientLayer addAnimation:animateLayer forKey:@"colorChange"];
    self.switchGradientLayer.colors = self.offGradientColors;
  } else {
    CABasicAnimation *animateLayer = [CABasicAnimation animationWithKeyPath:@"colors"];
    animateLayer.toValue = self.onGradientColors;
    animateLayer.duration = 0.2;
    animateLayer.removedOnCompletion = NO;
    animateLayer.fillMode = kCAFillModeForwards;
    animateLayer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.switchGradientLayer addAnimation:animateLayer forKey:@"colorChange"];
    self.switchGradientLayer.colors = self.onGradientColors;
  }
  
  id notification = self.specifier.properties[@"PostNotification"];
  if(notification) {
    if([notification isKindOfClass:[NSArray class]]) {
      NSArray *notificationObjects = (NSArray *)notification;
      for (NSString *notificationObject in notificationObjects) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:notificationObject object:nil userInfo:nil]];
      }
    } else if([notification isKindOfClass:[NSString class]]) {
      NSString *notificationObject = (NSString *)notification;
      [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:notificationObject object:nil userInfo:nil]];
    }
  }
  
  if(self.cellSwitch.isOn) {
    NSArray *connections = self.specifier.properties[@"connections"];
    for (NSString *connectingSwitch in connections) {
      NSNotification *notification = [NSNotification notificationWithName:connectingSwitch object:nil userInfo:nil];
      [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
  }
}

- (void)connectionWasEnabled {
  if(self.cellSwitch.isOn) {
    [self.cellSwitch setOn:NO animated:YES];
    [self switchChanged];
    [self updatePreferences:NO];
  }
}

- (void)updatePreferences:(bool)status {
  NSString *keyValue = [self.specifier.properties[@"key"] copy];
  [self.settings updateSettingsForKey:keyValue andValue:[NSNumber numberWithBool:status]];
}

- (void)setBackgroundColor:(UIColor *)color {
  [super setBackgroundColor:color];
  
  bool isBackgroundLight = [OBSUtilities isColorBright:self.backgroundColor];
  if(isBackgroundLight) {
    self.textLabel.textColor = [UIColor blackColor];
    self.detailTextLabel.textColor = [UIColor darkGrayColor];
  } else {
    self.textLabel.textColor = [UIColor whiteColor];
    self.detailTextLabel.textColor = [UIColor lightGrayColor];
  }
}
@end
