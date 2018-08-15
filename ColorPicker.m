//
//  ColorPicker.m
//
//  Created by Orangebananaspy on 2018-08-07.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import "OBSUtilities/ColorPicker.h"
#import "OBSUtilities/ColorSlider.h"
#import "OBSUtilities/OBSUtilities.h"
#import "OBSUtilities/OBSModalView.h"

@interface ColorPicker () <OBSModalDelegate>
@property (nonatomic, strong) OBSModalView *modal;

@property (nonatomic) CGRect mainRect;
@property (nonatomic) CGFloat mainCornerRadius;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *scrollViewStack;
@property (nonatomic, strong) UIImageView *previewColor;
@property (nonatomic, strong) UITextField *hexTextField;
@property (nonatomic, strong) UILabel *canEditMessage;
@property (nonatomic) CALayer *canEditMessageBorder;
@property (nonatomic, strong) ColorSlider *redSlider;
@property (nonatomic, strong) ColorSlider *greenSlider;
@property (nonatomic, strong) ColorSlider *blueSlider;
@property (nonatomic, strong) ColorSlider *alphaSlider;
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
  
  CGFloat height = 445.0f;
  self.mainRect = CGRectMake(5.0f, CGRectGetMidY(self.view.frame) - (height / 2.0f), self.view.frame.size.width - 10.0f, height);
  self.mainCornerRadius = 40.0f;
}

#pragma mark SETUP FUNCTIONS
- (void)setupContentView {
  OBSModalOptions *options = [[OBSModalOptions alloc] initWithModalFrame:self.mainRect cornerRadius:self.mainCornerRadius delegate:self isLightUI:self.lightUI selectTitleForButton:@"SELECT"];
  self.modal = [[OBSModalView alloc] initWithFrame:self.view.frame modalOptions:options];
}

- (void)setupContentSubviews {
  self.scrollView = [[UIScrollView alloc] initWithFrame:self.modal.contentView.frame];
  self.scrollView.layer.masksToBounds = YES;
  self.scrollView.layer.cornerRadius = self.mainCornerRadius;
  self.scrollView.layer.borderWidth = 1.5f;
  self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  
  self.scrollViewStack = [[UIStackView alloc] init];
  self.scrollViewStack.axis = UILayoutConstraintAxisVertical;
  self.scrollViewStack.distribution = UIStackViewDistributionEqualSpacing;
  self.scrollViewStack.alignment = UIStackViewAlignmentCenter;
  self.scrollViewStack.spacing = 15.0f;
  //  UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
  self.scrollViewStack.layoutMargins = UIEdgeInsetsMake(25.0f, 0, 0, 0);
  [self.scrollViewStack setLayoutMarginsRelativeArrangement:YES];
  
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
  self.scrollViewStack.translatesAutoresizingMaskIntoConstraints = NO;
  [self.scrollViewStack.topAnchor constraintEqualToAnchor:(self.scrollView.topAnchor)].active = YES;
  [self.scrollViewStack.leadingAnchor constraintEqualToAnchor:(self.scrollView.leadingAnchor)].active = YES;
  [self.scrollViewStack.trailingAnchor constraintEqualToAnchor:(self.scrollView.trailingAnchor)].active = YES;
  [self.scrollViewStack.bottomAnchor constraintEqualToAnchor:(self.scrollView.bottomAnchor)].active = YES;
  [self.scrollViewStack.centerXAnchor constraintEqualToAnchor:self.scrollView.centerXAnchor].active = YES;

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
  [self.view insertSubview:self.modal atIndex:0];
  [self.modal.contentView addSubview:self.scrollView];
  [self.scrollView addSubview:self.scrollViewStack];
  [self.scrollViewStack addArrangedSubview:self.previewColor];
  [self.scrollViewStack addArrangedSubview:self.hexTextField];
  [self.scrollViewStack addArrangedSubview:self.redSlider];
  [self.scrollViewStack addArrangedSubview:self.greenSlider];
  [self.scrollViewStack addArrangedSubview:self.blueSlider];
  [self.scrollViewStack addArrangedSubview:self.alphaSlider];
}

#pragma mark APPLY COLOR TO PICKER UI
- (void)applyColor {
  if(self.modal.isEclipseEnabled) {    
    self.scrollView.layer.borderColor = self.modal.secondaryColor.CGColor;

    self.previewColor.layer.borderColor = self.modal.secondaryColor.CGColor;
    
    self.hexTextField.backgroundColor = self.modal.secondaryColor;
    self.hexTextField.textColor = self.modal.secondaryTextColor;
    [[UITextField appearance] setTintColor:self.modal.secondaryTextColor];
    self.canEditMessage.textColor = self.modal.secondaryTextColor;
    self.canEditMessageBorder.borderColor = self.modal.secondaryTextColor.CGColor;
  } else if(self.lightUI) {
    self.scrollView.layer.borderColor = self.modal.secondaryColor.CGColor;

    self.previewColor.layer.borderColor = self.modal.secondaryColor.CGColor;
    
    self.hexTextField.backgroundColor = self.modal.secondaryColor;
    self.hexTextField.textColor = self.modal.secondaryTextColor;
    [[UITextField appearance] setTintColor:self.modal.secondaryTextColor];
    self.canEditMessage.textColor = self.modal.secondaryTextColor;
    self.canEditMessageBorder.borderColor = self.modal.secondaryTextColor.CGColor;
  } else {
    self.scrollView.layer.borderColor = self.modal.primaryColor.CGColor;

    self.previewColor.layer.borderColor = self.modal.primaryColor.CGColor;
    
    self.hexTextField.backgroundColor = self.modal.primaryColor;
    self.hexTextField.textColor = self.modal.primaryTextColor;
    [[UITextField appearance] setTintColor:self.modal.primaryTextColor];
    self.canEditMessage.textColor = self.modal.primaryTextColor;
    self.canEditMessageBorder.borderColor = self.modal.primaryTextColor.CGColor;
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
