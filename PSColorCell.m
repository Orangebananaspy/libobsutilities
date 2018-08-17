//
//  PSColorCell.m
//
//  Created by Orangebananaspy on 2018-08-08.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import "OBSUtilities/PSColorCell.h"
#import "OBSUtilities/OBSUtilities.h"

#define tweakPreferencePath @"/var/mobile/Library/Preferences/"

@interface PSColorCell ()
@property (nonatomic, weak) PSTweakSettings *settings;
@property (nonatomic, strong) UIImageView *colorImageView;
@property (nonatomic, strong) ColorPicker *pickerController;
@property (nonatomic, strong, setter=setColorForCell:) UIColor *color;
@end

@implementation PSColorCell
@synthesize color = _color;

- (instancetype)initWithStyle:(int)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
  self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    self.settings = [PSTweakSettings instanceWithName:[specifier.properties[@"preferenceName"] copy] andUser:[specifier.properties[@"preferenceName"] copy]];
    
    self.specifier = specifier;
    
    NSString *keyValue = [specifier.properties[@"key"] copy];
    NSString *keyLabel = [specifier.properties[@"keyLabel"] copy];
    
    NSString *defaultColorHex;
    if(!(defaultColorHex = [self.settings getSettingsForKey:keyValue])) {
      defaultColorHex = [specifier.properties[@"default"] copy];
    }
    
    CGFloat height = self.contentView.frame.size.height;
    self.colorImageView = [[UIImageView alloc] initWithFrame:(CGRect) {{0, 0}, {height, height}}];
    self.colorImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.colorImageView.clipsToBounds = YES;
    self.colorImageView.layer.borderWidth = 0.5f;
    self.colorImageView.layer.cornerRadius = height / 4.0f;
    self.colorImageView.layer.masksToBounds = YES;
    self.accessoryView = self.colorImageView;
    
    self.pickerController = [[ColorPicker alloc] init];
    self.pickerController.delegate = self;
    self.pickerController.providesPresentationContextTransitionStyle = YES;
    self.pickerController.definesPresentationContext = YES;
    if(specifier.properties[@"isLighUI"]) self.pickerController.lightUI = [specifier.properties[@"isLighUI"] boolValue];
    self.pickerController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    self.color = [OBSUtilities colorFromHexString:defaultColorHex];
    self.textLabel.text = keyLabel;
    self.detailTextLabel.text = defaultColorHex;
  }
  return self;
}

- (void)setBackgroundColor:(UIColor *)color {
  [super setBackgroundColor:color];
  
  bool isBackgroundLight = [OBSUtilities isColorBright:self.backgroundColor];
  if(isBackgroundLight) {
    self.textLabel.textColor = [UIColor blackColor];
    self.detailTextLabel.textColor = [UIColor darkGrayColor];
    self.colorImageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
  } else {
    self.textLabel.textColor = [UIColor whiteColor];
    self.detailTextLabel.textColor = [UIColor lightGrayColor];
    self.colorImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
  }
}

- (void)setColorForCell:(UIColor *)color {
  _color = color;
  
  UIImage *image = [OBSUtilities imagePixelFromColor:color];
  self.colorImageView.image = image;
}

- (void)colorPickerReturnedWithColor:(UIColor *)color andHexString:(NSString *)hexString {
  self.color = color;
  self.detailTextLabel.text = hexString;
  [self saveSettingsWithValue:hexString];
}

- (void)saveSettingsWithValue:(NSString *)hexString {
  NSString *keyValue = [self.specifier.properties[@"key"] copy];
  [self.settings updateSettingsForKey:keyValue andValue:hexString];

  id notification = self.specifier.properties[@"PostNotification"];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  
  if(selected) {
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    [UINavigationController attemptRotationToDeviceOrientation];
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    [controller presentViewController:self.pickerController animated:YES completion:nil];
    [self.pickerController setInitialColor:self.color];
  }
}
@end
