//
//  ColorPicker.m
//
//  Created by Orangebananaspy on 2018-08-07.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import "ColorPicker.h"
#import "ColorSlider.h"
#import "OBSUtilities.h"

@interface ColorPicker ()
@property (nonatomic) UIColor *primaryColor;
@property (nonatomic) UIColor *secondaryColor;
@property (nonatomic) UIColor *primaryTextColor;
@property (nonatomic) UIColor *secondaryTextColor;
@property (nonatomic) CGRect mainRect;
@property (nonatomic) CGFloat mainCornerRadius;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *scrollViewStack;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIImageView *previewColor;
@property (nonatomic, strong) UITextField *hexTextField;
@property (nonatomic, strong) UILabel *canEditMessage;
@property (nonatomic) CALayer *canEditMessageBorder;
@property (nonatomic, strong) ColorSlider *redSlider;
@property (nonatomic, strong) ColorSlider *greenSlider;
@property (nonatomic, strong) ColorSlider *blueSlider;
@property (nonatomic, strong) ColorSlider *alphaSlider;
@property (nonatomic) BOOL isEclipseEnabled;
@end

@implementation ColorPicker
- (ColorPicker *)init {
  self = [super init];
  if (self) {
    self.lightUI = YES;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self configColorPicker];
  [self setupShadowView];
  [self setupContentView];
  [self setupContentSubviews];
  [self addViewsInOrder];
  [self setupConstraints];
  [self applyColor];
  [self updateToColor:[OBSUtilities colorFromHexString:@"#000000"]];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  
  // resize scrollview if needed
  self.scrollView.contentSize = CGSizeMake(self.scrollViewStack.frame.size.width, self.scrollViewStack.frame.size.height);
}

#pragma mark PICKER CONFIGURATION
- (void)configColorPicker {
  // turn to portrait as its better visually
  [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
  
  // make background clear so we can see the viewcontroller behind this modal view
  self.view.backgroundColor = [UIColor clearColor];
  
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
  
  // setup default values for the picker
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
  
  CGFloat height = 445.0f;
  self.mainRect = CGRectMake(5.0f, CGRectGetMidY(self.view.frame) - (height / 2.0f), self.view.frame.size.width - 10.0f, height);
  self.mainCornerRadius = 40.0f;
}

#pragma mark SETUP FUNCTIONS
- (void)setupShadowView {
  self.shadowView = [[UIView alloc] initWithFrame:self.mainRect];
  self.shadowView.backgroundColor = [UIColor clearColor];
  self.shadowView.clipsToBounds = NO;
  self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
  self.shadowView.layer.shadowRadius = 10.0f;
  self.shadowView.layer.shadowOpacity = 0.4f;
  self.shadowView.layer.masksToBounds = NO;
  self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.shadowView.bounds cornerRadius:self.mainCornerRadius].CGPath;
  self.shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setupContentView {
  self.contentView = [[UIView alloc] initWithFrame:self.mainRect];
  self.contentView.clipsToBounds = YES;
  self.contentView.layer.masksToBounds = YES;
  self.contentView.layer.cornerRadius = self.mainCornerRadius;
//  UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerTopLeft| UIRectCornerTopRight cornerRadii:CGSizeMake(self.mainCornerRadius, self.mainCornerRadius)];
//  CAShapeLayer *maskLayer = [CAShapeLayer layer];
//  maskLayer.frame = self.contentView.bounds;
//  maskLayer.path = maskPath.CGPath;
//  self.contentView.layer.mask = maskLayer;
  self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setupContentSubviews {
  self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [self.closeButton setTitle:@"X" forState:UIControlStateNormal];
  self.closeButton.layer.masksToBounds = YES;
  self.closeButton.layer.cornerRadius = 20.0f;
  self.closeButton.titleLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", self.closeButton.titleLabel.font.fontName] size:20.0f];
  
  self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
  self.scrollView.layer.masksToBounds = YES;
  self.scrollView.layer.cornerRadius = self.mainCornerRadius;
  self.scrollView.layer.borderWidth = 1.5f;
  
  self.scrollViewStack = [[UIStackView alloc] init];
  self.scrollViewStack.axis = UILayoutConstraintAxisVertical;
  self.scrollViewStack.distribution = UIStackViewDistributionEqualSpacing;
  self.scrollViewStack.alignment = UIStackViewAlignmentCenter;
  self.scrollViewStack.spacing = 15.0f;
  //  UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  self.scrollViewStack.layoutMargins = UIEdgeInsetsMake(25.0f, 0, 0, 0);
  [self.scrollViewStack setLayoutMarginsRelativeArrangement:YES];
  
  self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [self.selectButton addTarget:self action:@selector(selectButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [self.selectButton setTitle:@"SELECT" forState:UIControlStateNormal];
  self.selectButton.titleLabel.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", self.selectButton.titleLabel.font.fontName] size:14.0f];
  self.selectButton.layer.masksToBounds = YES;
  self.selectButton.layer.cornerRadius =  20.5f;
  
  self.previewColor = [[UIImageView alloc] init];
  self.previewColor.clipsToBounds = YES;
  self.previewColor.layer.masksToBounds = YES;
  self.previewColor.layer.cornerRadius = 55.0f / 2.0f;
  self.previewColor.layer.borderWidth = 1.0f;
  
  self.hexTextField = [[UITextField alloc] init];
  [self.hexTextField setDelegate:self];
  [self.hexTextField setReturnKeyType:UIReturnKeyDone];
  [self.hexTextField.layer setCornerRadius:14];
  self.hexTextField.textAlignment = NSTextAlignmentCenter;
  self.hexTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
  self.hexTextField.clipsToBounds = YES;
  self.hexTextField.layer.masksToBounds = YES;
  self.hexTextField.text = [OBSUtilities hexStringFromColor:[UIColor redColor]];
  
  self.canEditMessage = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 50, 40)];
  self.canEditMessage.text = @"Tap to Edit";
  self.canEditMessage.font = [UIFont fontWithName:[NSString stringWithFormat:@"%@", self.canEditMessage.font.fontName] size:10.0f];
  self.canEditMessage.textAlignment = NSTextAlignmentCenter;
  self.canEditMessage.lineBreakMode = NSLineBreakByWordWrapping;
  self.canEditMessage.numberOfLines = 0;
  self.canEditMessage.clipsToBounds = YES;
  self.canEditMessage.layer.masksToBounds = YES;
  self.canEditMessageBorder = [CALayer layer];
  self.canEditMessageBorder.borderWidth = 1;
  self.canEditMessageBorder.frame = CGRectMake(-1, -1, CGRectGetWidth(self.canEditMessage.frame), CGRectGetHeight(self.canEditMessage.frame) + 2);
  [self.canEditMessage.layer addSublayer:self.canEditMessageBorder];
  self.hexTextField.leftView = self.canEditMessage;
  self.hexTextField.leftViewMode = UITextFieldViewModeAlways;
  
  self.redSlider = [[ColorSlider alloc] initWithFrame:CGRectMake(0, 0, self.mainRect.size.width - (15.0f * 4.0f), 20) withType:kRed];
  [self.redSlider minMaxOfColor:[OBSUtilities colorFromHexString:@"595457"]];
  [self.redSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
  
  self.greenSlider = [[ColorSlider alloc] initWithFrame:CGRectMake(0, 0, self.mainRect.size.width - (15.0f * 4.0f), 20) withType:kGreen];
  [self.greenSlider minMaxOfColor:[OBSUtilities colorFromHexString:@"595457"]];
  [self.greenSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
  
  self.blueSlider = [[ColorSlider alloc] initWithFrame:CGRectMake(0, 0, self.mainRect.size.width - (15.0f * 4.0f), 20) withType:kBlue];
  [self.blueSlider minMaxOfColor:[OBSUtilities colorFromHexString:@"595457"]];
  [self.blueSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
  
  self.alphaSlider = [[ColorSlider alloc] initWithFrame:CGRectMake(0, 0, self.mainRect.size.width - (15.0f * 4.0f), 20) withType:kAlpha];
  [self.alphaSlider minMaxOfColor:[OBSUtilities colorFromHexString:@"595457"]];
  [self.alphaSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)setupConstraints {
  self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.scrollView.heightAnchor constraintEqualToConstant:300.0f].active = YES;
  [self.scrollView.widthAnchor constraintEqualToConstant:self.mainRect.size.width - (15.0f * 2.0f)].active = YES;
  [self.scrollView.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:15.0f].active = YES;
  [self.scrollView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
  
  self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.closeButton.heightAnchor constraintEqualToConstant:40.0f].active = YES;
  [self.closeButton.widthAnchor constraintEqualToConstant:40.0f].active = YES;
  [self.closeButton.leftAnchor constraintEqualToAnchor:self.contentView.leftAnchor constant:15.0f].active = YES;
  [self.closeButton.bottomAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:-15.0f].active = YES;
  
  self.scrollViewStack.translatesAutoresizingMaskIntoConstraints = NO;
  [self.scrollViewStack.topAnchor constraintEqualToAnchor:(self.scrollView.topAnchor)].active = YES;
  [self.scrollViewStack.leadingAnchor constraintEqualToAnchor:(self.scrollView.leadingAnchor)].active = YES;
  [self.scrollViewStack.trailingAnchor constraintEqualToAnchor:(self.scrollView.trailingAnchor)].active = YES;
  [self.scrollViewStack.bottomAnchor constraintEqualToAnchor:(self.scrollView.bottomAnchor)].active = YES;
  [self.scrollViewStack.centerXAnchor constraintEqualToAnchor:self.scrollView.centerXAnchor].active = YES;
  
  self.selectButton.translatesAutoresizingMaskIntoConstraints = NO;
  [self.selectButton.heightAnchor constraintEqualToConstant:40.0f].active = YES;
  [self.selectButton.widthAnchor constraintEqualToConstant:70.0f].active = YES;
  [self.selectButton.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor constant:0.0f].active = YES;
  [self.selectButton.topAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:15.0f].active = YES;
  
  [self.previewColor.heightAnchor constraintEqualToConstant:55.0f].active = YES;
  [self.previewColor.widthAnchor constraintEqualToConstant:120.0f].active = YES;
  
  [self.hexTextField.heightAnchor constraintEqualToConstant:40.0f].active = true;
  [self.hexTextField.widthAnchor constraintEqualToConstant:250.0f].active = true;
  
  [self.redSlider.heightAnchor constraintEqualToConstant:20.0f].active = true;
  [self.redSlider.widthAnchor constraintEqualToConstant:self.mainRect.size.width - (15.0f * 4.0f)].active = true;
  
  [self.greenSlider.heightAnchor constraintEqualToConstant:20.0f].active = true;
  [self.greenSlider.widthAnchor constraintEqualToConstant:self.mainRect.size.width - (15.0f * 4.0f)].active = true;
  
  [self.blueSlider.heightAnchor constraintEqualToConstant:20.0f].active = true;
  [self.blueSlider.widthAnchor constraintEqualToConstant:self.mainRect.size.width - (15.0f * 4.0f)].active = true;
  
  [self.alphaSlider.heightAnchor constraintEqualToConstant:20.0f].active = true;
  [self.alphaSlider.widthAnchor constraintEqualToConstant:self.mainRect.size.width - (15.0f * 4.0f)].active = true;
}

#pragma mark ADD SUBVIEWS
- (void)addViewsInOrder {
  [self.view insertSubview:self.shadowView atIndex:0];
  [self.view insertSubview:self.contentView atIndex:1];
  [self.contentView addSubview:self.scrollView];
  [self.contentView addSubview:self.closeButton];
  [self.scrollView addSubview:self.scrollViewStack];
  [self.contentView addSubview:self.selectButton];
  [self.scrollViewStack addArrangedSubview:self.previewColor];
  [self.scrollViewStack addArrangedSubview:self.hexTextField];
  [self.scrollViewStack addArrangedSubview:self.redSlider];
  [self.scrollViewStack addArrangedSubview:self.greenSlider];
  [self.scrollViewStack addArrangedSubview:self.blueSlider];
  [self.scrollViewStack addArrangedSubview:self.alphaSlider];
}

#pragma mark APPLY COLOR TO PICKER UI
- (void)applyColor {
  if(self.isEclipseEnabled) {
    self.shadowView.layer.shadowColor = self.secondaryColor.CGColor;
    
    self.contentView.layer.backgroundColor = self.primaryColor.CGColor;
    self.scrollView.layer.borderColor = self.secondaryColor.CGColor;
    
    self.closeButton.backgroundColor = self.secondaryColor;
    [self.closeButton setTitleColor:self.secondaryTextColor forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[self.secondaryTextColor colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
    
    self.selectButton.backgroundColor = self.secondaryColor;
    [self.selectButton setTitleColor:self.secondaryTextColor forState:UIControlStateNormal];
    [self.selectButton setTitleColor:[self.secondaryTextColor colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
    
    self.previewColor.layer.borderColor = self.secondaryColor.CGColor;
    
    self.hexTextField.backgroundColor = self.secondaryColor;
    self.hexTextField.textColor = self.secondaryTextColor;
    [[UITextField appearance] setTintColor:self.secondaryTextColor];
    self.canEditMessage.textColor = self.secondaryTextColor;
    self.canEditMessageBorder.borderColor = self.secondaryTextColor.CGColor;
  } else if(self.lightUI) {
    self.shadowView.layer.shadowColor = self.secondaryColor.CGColor;
    
    self.contentView.layer.backgroundColor = self.primaryColor.CGColor;
    self.scrollView.layer.borderColor = self.secondaryColor.CGColor;
    
    self.closeButton.backgroundColor = self.secondaryColor;
    [self.closeButton setTitleColor:self.secondaryTextColor forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[self.secondaryTextColor colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
    
    self.selectButton.backgroundColor = self.secondaryColor;
    [self.selectButton setTitleColor:self.secondaryTextColor forState:UIControlStateNormal];
    [self.selectButton setTitleColor:[self.secondaryTextColor colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
    
    self.previewColor.layer.borderColor = self.secondaryColor.CGColor;
    
    self.hexTextField.backgroundColor = self.secondaryColor;
    self.hexTextField.textColor = self.secondaryTextColor;
    [[UITextField appearance] setTintColor:self.secondaryTextColor];
    self.canEditMessage.textColor = self.secondaryTextColor;
    self.canEditMessageBorder.borderColor = self.secondaryTextColor.CGColor;
  } else {
    self.shadowView.layer.shadowColor = self.primaryColor.CGColor;
    
    self.contentView.layer.backgroundColor = self.secondaryColor.CGColor;
    self.scrollView.layer.borderColor = self.primaryColor.CGColor;
    
    self.closeButton.backgroundColor = self.primaryColor;
    [self.closeButton setTitleColor:self.primaryTextColor forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[self.primaryTextColor colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
    
    self.selectButton.backgroundColor = self.primaryColor;
    [self.selectButton setTitleColor:self.primaryTextColor forState:UIControlStateNormal];
    [self.selectButton setTitleColor:[self.primaryTextColor colorWithAlphaComponent:0.6f] forState:UIControlStateHighlighted];
    
    self.previewColor.layer.borderColor = self.primaryColor.CGColor;
    
    self.hexTextField.backgroundColor = self.primaryColor;
    self.hexTextField.textColor = self.primaryTextColor;
    [[UITextField appearance] setTintColor:self.primaryTextColor];
    self.canEditMessage.textColor = self.primaryTextColor;
    self.canEditMessageBorder.borderColor = self.primaryTextColor.CGColor;
  }
}

#pragma mark COLOR MODIFIERS
- (void)setInitialColor:(UIColor *)color {
  [self updateToColor:color];
}

- (void)updateToColor:(UIColor *)color {
  [self.redSlider minMaxOfColor:color];
  [self.greenSlider minMaxOfColor:color];
  [self.blueSlider minMaxOfColor:color];
  [self.alphaSlider minMaxOfColor:color];
  self.hexTextField.text = [OBSUtilities hexStringFromColor:color];
  
  self.previewColor.image = [OBSUtilities imageFromColor:color withSize:(CGSize) {60.0, 60.0}];
}

- (void)sliderValueChanged {
  UIColor *color = [UIColor colorWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value alpha:self.alphaSlider.value];
  [self updateToColor:color];
}

#pragma mark TEXTFIELD DELEGATE FUNCTIONS
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  if (textField.text.length < 9) {
    if([OBSUtilities isValidHexColorLetter:string]) {
      if (textField.text.length == 0 && ![string isEqual:@"#"]) {
        textField.text = [NSString stringWithFormat:@"#%@", [string uppercaseString]];
      } else {
        textField.text = [textField.text stringByAppendingString:[string uppercaseString]];
      }
    }
  }

  if (string.length == 0 && range.length == 1) {
    return YES;
  }
  
  return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  UIColor *color = [OBSUtilities colorFromHexString:self.hexTextField.text];
  [self updateToColor:color];
  [textField resignFirstResponder];
  return YES;
}

#pragma mark PICKER EXIT FUNCTIONS
- (void)selectButtonPressed {
  if (self.delegate) {
    if ([self.delegate respondsToSelector:@selector(colorPickerReturnedWithColor:andHexString:)]) {
      UIColor *color = [UIColor colorWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value alpha:self.alphaSlider.value];
      [self.delegate colorPickerReturnedWithColor:color andHexString:self.hexTextField.text];
    }
  }
  [self closeButtonPressed];
}

- (void)closeButtonPressed {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}
@end
