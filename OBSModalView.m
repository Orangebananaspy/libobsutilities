//
//  OBSModalView.m
//
//  Created by Orangebananaspy on 2018-08-14.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import "OBSUtilities/OBSModalView.h"
#import "OBSUtilities/OBSUtilities.h"

#pragma mark IMPLEMENTATION OBSModalOptions
@implementation OBSModalOptions
- (OBSModalOptions *)initWithModalFrame:(CGRect)frame cornerRadius:(CGFloat)radius delegate:(id <OBSModalDelegate>)modalDelegate isLightUI:(BOOL)light selectTitleForButton:(NSString *)title {
  self = [super init];
  if(self) {
    self.modalFrame = frame;
    self.cornerRadius = radius;
    self.delegate = modalDelegate;
    self.lightUI = light;
    self.selectButtonTitle = title;
  }
  return self;
}
@end

#pragma mark IMPLEMENTATION OBSModalView
@interface OBSModalView ()
@property (nonatomic, strong) OBSModalOptions *modalOptions;
@property (nonatomic, strong, readwrite) UIView *contentView;
@property (nonatomic, strong, readwrite) UIView *topView;

@property (nonatomic, strong, readwrite) UIColor *primaryColor;
@property (nonatomic, strong, readwrite) UIColor *secondaryColor;
@property (nonatomic, strong, readwrite) UIColor *primaryTextColor;
@property (nonatomic, strong, readwrite) UIColor *secondaryTextColor;

@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIView *panelView;
@property (nonatomic, assign, readwrite) BOOL isEclipseEnabled;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *selectButton;

@property (nonatomic, strong) UIView *extraTopView;
@end

@implementation OBSModalView
- (OBSModalView *)initWithFrame:(CGRect)frame modalOptions:(OBSModalOptions *)options {
  self = [super initWithFrame:frame];
  if(self) {
    self.modalOptions = options;
    self.backgroundColor = [UIColor clearColor];
    
    // is eclipse enabled for settings
    self.isEclipseEnabled = false;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Eclipse.dylib"]) {
      if ([fileManager fileExistsAtPath:@"/var/mobile/Library/Preferences/com.gmoran.eclipse.plist"]) {
        NSDictionary *eclipseSettings = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.gmoran.eclipse.plist"];
        if(eclipseSettings[@"enabled"] && [eclipseSettings[@"enabled"] boolValue]) {
          self.isEclipseEnabled = (eclipseSettings[@"EnabledApps-com.apple.Preferences"] && [eclipseSettings[@"EnabledApps-com.apple.Preferences"] boolValue]);
        }
      }
    }
        
    // setup default values
    if(self.isEclipseEnabled) {
      self.primaryColor = [OBSUtilities colorFromHexString:@"212121"];
      self.secondaryColor = [OBSUtilities colorFromHexString:@"616161"];
      self.primaryTextColor = [OBSUtilities colorFromHexString:@"616161"];
      self.secondaryTextColor = [OBSUtilities colorFromHexString:@"212121"];
    } else {
      self.primaryColor = [OBSUtilities colorFromHexString:@"ECECEC"];
      self.secondaryColor = [OBSUtilities colorFromHexString:@"22313F"];
      self.primaryTextColor = [OBSUtilities colorFromHexString:@"22313F"];
      self.secondaryTextColor = [OBSUtilities colorFromHexString:@"ECECEC"];
    }
    
    [self setupViews];
    [self addSubviewsInOrder];
    [self setupConstraints];
    [self applyColor];

  }
  return self;
}

- (void)setupViews {
  self.shadowView = [[UIView alloc] initWithFrame:self.modalOptions.modalFrame];
  self.shadowView.backgroundColor = [UIColor clearColor];
  self.shadowView.clipsToBounds = NO;
  self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  self.shadowView.layer.shadowRadius = 10.0f;
  self.shadowView.layer.shadowOpacity = 0.4f;
  self.shadowView.layer.masksToBounds = NO;
  self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds cornerRadius:self.modalOptions.cornerRadius].CGPath;
  self.shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  self.panelView = [[UIView alloc] initWithFrame:self.modalOptions.modalFrame];
  self.panelView.clipsToBounds = YES;
  self.panelView.layer.masksToBounds = YES;
  self.panelView.layer.cornerRadius = self.modalOptions.cornerRadius;
  self.panelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
  self.contentView.layer.masksToBounds = YES;
  self.contentView.layer.cornerRadius = self.modalOptions.cornerRadius;
  self.contentView.layer.borderWidth = 1.5f;
  
  self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.closeButton addTarget:self.modalOptions.delegate action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [self.closeButton setTitle:@"X" forState:UIControlStateNormal];
  self.closeButton.layer.masksToBounds = YES;
  self.closeButton.layer.cornerRadius = 20.0f;
  self.closeButton.titleLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", self.closeButton.titleLabel.font.fontName] size:20.0f];
  
  self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.selectButton addTarget:self.modalOptions.delegate action:@selector(selectButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [self.selectButton setTitle:self.modalOptions.selectButtonTitle forState:UIControlStateNormal];
  self.selectButton.titleLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", self.selectButton.titleLabel.font.fontName] size:14.0f];
  self.selectButton.layer.masksToBounds = YES;
  self.selectButton.layer.cornerRadius =  20.5f;
  
  self.extraTopView = [[UIView alloc] initWithFrame:CGRectZero];
  self.extraTopView.layer.masksToBounds = YES;
  self.extraTopView.clipsToBounds = YES;
  self.extraTopView.layer.cornerRadius = 20.0f;
  self.extraTopView.backgroundColor = [UIColor clearColor];
  
  self.topView = [[UIView alloc] initWithFrame:CGRectZero];
  self.topView.layer.masksToBounds = YES;
  self.topView.layer.cornerRadius = 20.0f;
  self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setupConstraints {
  self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.contentView.heightAnchor constraintEqualToConstant:300.0f].active = YES;
  [self.contentView.widthAnchor constraintEqualToConstant:self.modalOptions.modalFrame.size.width - (15.0f * 2.0f)].active = YES;
  [self.contentView.leftAnchor constraintEqualToAnchor:self.panelView.leftAnchor constant:15.0f].active = YES;
  [self.contentView.centerYAnchor constraintEqualToAnchor:self.panelView.centerYAnchor].active = YES;
  
  self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.closeButton.heightAnchor constraintEqualToConstant:40.0f].active = YES;
  [self.closeButton.widthAnchor constraintEqualToConstant:40.0f].active = YES;
  [self.closeButton.leftAnchor constraintEqualToAnchor:self.panelView.leftAnchor constant:15.0f].active = YES;
  [self.closeButton.bottomAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:-15.0f].active = YES;
  
  self.selectButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.selectButton.heightAnchor constraintEqualToConstant:40.0f].active = YES;
  [self.selectButton.widthAnchor constraintEqualToConstant:70.0f].active = YES;
  [self.selectButton.centerXAnchor constraintEqualToAnchor:self.panelView.centerXAnchor constant:0.0f].active = YES;
  [self.selectButton.topAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:15.0f].active = YES;
  
  self.extraTopView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.extraTopView.leftAnchor constraintEqualToAnchor:self.panelView.leftAnchor constant:40.0f + (15.0f * 2)].active = YES;
  [self.extraTopView.rightAnchor constraintEqualToAnchor:self.panelView.rightAnchor constant:-15.0f].active = YES;
  [self.extraTopView.bottomAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:-15.0f].active = YES;
  [self.extraTopView.heightAnchor constraintEqualToConstant:40.0f].active = YES;
}

- (void)applyColor {
  if(self.isEclipseEnabled) {
    self.shadowView.layer.shadowColor = self.secondaryColor.CGColor;
    
    self.panelView.layer.backgroundColor = self.primaryColor.CGColor;
    self.contentView.layer.borderColor = self.secondaryColor.CGColor;
    
    self.closeButton.backgroundColor = self.secondaryColor;
    [self.closeButton setTitleColor:self.secondaryTextColor forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[self.secondaryTextColor colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
    
    self.selectButton.backgroundColor = self.secondaryColor;
    [self.selectButton setTitleColor:self.secondaryTextColor forState:UIControlStateNormal];
    [self.selectButton setTitleColor:[self.secondaryTextColor colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
  } else if(self.modalOptions.lightUI) {
    self.shadowView.layer.shadowColor = self.secondaryColor.CGColor;
    
    self.panelView.layer.backgroundColor = self.primaryColor.CGColor;
    self.contentView.layer.borderColor = self.secondaryColor.CGColor;
    
    self.closeButton.backgroundColor = self.secondaryColor;
    [self.closeButton setTitleColor:self.secondaryTextColor forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[self.secondaryTextColor colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
    
    self.selectButton.backgroundColor = self.secondaryColor;
    [self.selectButton setTitleColor:self.secondaryTextColor forState:UIControlStateNormal];
    [self.selectButton setTitleColor:[self.secondaryTextColor colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
  } else {
    self.shadowView.layer.shadowColor = self.primaryColor.CGColor;
    
    self.panelView.layer.backgroundColor = self.secondaryColor.CGColor;
    self.contentView.layer.borderColor = self.primaryColor.CGColor;
    
    self.closeButton.backgroundColor = self.primaryColor;
    [self.closeButton setTitleColor:self.primaryTextColor forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[self.primaryTextColor colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
    
    self.selectButton.backgroundColor = self.primaryColor;
    [self.selectButton setTitleColor:self.primaryTextColor forState:UIControlStateNormal];
    [self.selectButton setTitleColor:[self.primaryTextColor colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
  }
}

- (void)addSubviewsInOrder {
  [self insertSubview:self.shadowView atIndex:0];
  [self insertSubview:self.panelView atIndex:1];
  [self.panelView addSubview:self.contentView];
  [self.panelView addSubview:self.closeButton];
  [self.panelView addSubview:self.selectButton];
  [self.panelView addSubview:self.extraTopView];
  [self.extraTopView addSubview:self.topView];
}
@end
