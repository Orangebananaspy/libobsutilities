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
#import <dlfcn.h>

#define ResourcePath @"/var/mobile/Library/Preferences/OBSUtilities"
//#define ResourceRecentColorPath @"/Users/rutvik/Desktop/tweak/libobsutilities/layout/var/mobile/Library/Preferences/OBSUtilities/recent_colors.plist"
#define ResourceRecentColorPath @"/var/mobile/Library/Preferences/OBSUtilities/recent_colors.plist"
#define RecentCellIdentifier @"RecentColorCell"
#define NUM_RECENT_CELL ((int) 6)
#define RECENT_CELL_SIZE ((CGSize) {30.0f, 30.0f})

@interface ColorPicker () <OBSModalDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) OBSModalView *modal;

@property (nonatomic) CGRect mainRect;
@property (nonatomic) CGFloat mainCornerRadius;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *scrollViewStack;
@property (nonatomic, strong) UIImageView *previewColor;
@property (nonatomic, strong) UITextField *hexTextField;
@property (nonatomic, strong) UILabel *canEditMessage;
@property (nonatomic) CALayer *canEditMessageBorder;
@property (nonatomic, strong) UIView *duplicatePasteView;
@property (nonatomic, strong) UIButton *duplicateButton;
@property (nonatomic, strong) UIButton *pasteButton;
@property (nonatomic, strong) ColorSlider *redSlider;
@property (nonatomic, strong) ColorSlider *greenSlider;
@property (nonatomic, strong) ColorSlider *blueSlider;
@property (nonatomic, strong) ColorSlider *alphaSlider;
@property (nonatomic, strong) UIImage *duplicateButtonImage;
@property (nonatomic, strong) UIImage *pasteButtonImage;

@property (nonatomic, strong) UICollectionView *recentCollectionView;
@property (nonatomic, strong) NSMutableDictionary *recentColorDictionary;
@property (nonatomic, strong) NSMutableArray *recentColors;
@end

@implementation ColorPicker
- (ColorPicker *)init {
  self = [super init];
  if (self) {
    // load library if not loaded (mainly needed for Cephie framework)
    dlopen("/usr/lib/libOBSUtilities.dylib", RTLD_LAZY | RTLD_LOCAL);
    
    self.lightUI = YES;
  }
  return self;
}

- (void)grabRecentColorData {
  self.recentColorDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:ResourceRecentColorPath];
  if(!self.recentColorDictionary) {
    self.recentColors = [@[@"#00000000", @"#00000000", @"#00000000", @"#00000000", @"#00000000", @"#00000000"] mutableCopy];
    self.recentColorDictionary = [NSMutableDictionary dictionary];
    [self.recentColorDictionary setObject:self.recentColors forKey:@"Colors"];
  } else {
    self.recentColors = self.recentColorDictionary[@"Colors"];
  }
  
  [self.recentCollectionView reloadData];
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
  [self grabRecentColorData];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  // hide modal view so we can spring it in
  self.modal.frame = CGRectOffset(self.modal.frame, 0, self.view.frame.size.height);
  
  // show modal view with spring animation
  [UIView animateWithDuration:0.5f delay:0 usingSpringWithDamping:0.6f initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
    self.modal.frame = CGRectOffset(self.modal.frame, 0, -self.view.frame.size.height);
  } completion:^(BOOL finished) {
    if(finished) {
    }
  }];
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
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return NUM_RECENT_CELL;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RecentCellIdentifier forIndexPath:indexPath];
  if(self.recentColors) {
    UIColor *cellColor = [OBSUtilities colorFromHexString:[self.recentColors objectAtIndex:indexPath.row]];
    cell.backgroundColor = cellColor;
  }
  cell.layer.cornerRadius = RECENT_CELL_SIZE.width / 2.0f;
  return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return RECENT_CELL_SIZE;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  NSInteger verticalInset = (self.modal.topView.frame.size.height - RECENT_CELL_SIZE.height) / 2.0f;
  return UIEdgeInsetsMake(verticalInset, 5.5f, verticalInset, 5.5f);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  UIColor *selectedColor = [OBSUtilities colorFromHexString:[self.recentColors objectAtIndex:indexPath.row]];
  [self updateToColor:selectedColor];
}

- (void)setupContentView {
  OBSModalOptions *options = [[OBSModalOptions alloc] initWithModalFrame:self.mainRect cornerRadius:self.mainCornerRadius delegate:self isLightUI:self.lightUI selectTitleForButton:@"SELECT"];
  self.modal = [[OBSModalView alloc] initWithFrame:self.view.frame modalOptions:options];
}

- (void)setupContentSubviews {
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.minimumInteritemSpacing = 2.5f;
  
  self.recentCollectionView = [[UICollectionView alloc] initWithFrame:self.modal.topView.frame collectionViewLayout:layout];
  self.recentCollectionView.layer.masksToBounds = YES;
  self.recentCollectionView.scrollEnabled = false;
  self.recentCollectionView.layer.cornerRadius = self.modal.topView.layer.cornerRadius;
  self.recentCollectionView.layer.borderWidth = 1.4f;
  self.recentCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.recentCollectionView setDataSource:self];
  [self.recentCollectionView setDelegate:self];
  [self.recentCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:RecentCellIdentifier];
  self.recentCollectionView.backgroundColor = [UIColor clearColor];
  self.modal.topView.backgroundColor = [UIColor clearColor];
  
  self.scrollView = [[UIScrollView alloc] initWithFrame:self.modal.contentView.frame];
  self.scrollView.layer.masksToBounds = YES;
  self.scrollView.layer.cornerRadius = self.mainCornerRadius;
  self.scrollView.layer.borderWidth = 1.4f;
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

  self.duplicatePasteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
  self.duplicatePasteView.clipsToBounds = YES;
  self.duplicatePasteView.layer.masksToBounds = YES;

  CGSize imageScale = CGSizeMake(20, 20);
  self.duplicateButtonImage = [OBSUtilities newScale:imageScale forImage:[self copyImage]];
  self.pasteButtonImage = [OBSUtilities newScale:imageScale forImage:[self pasteImage]];
  
  self.duplicateButton = [UIButton buttonWithType:UIButtonTypeSystem];
  self.duplicateButton.frame = CGRectMake(0, 0, 30, 40);
  [self.duplicateButton setImage:self.duplicateButtonImage forState:UIControlStateNormal];
  [self.duplicateButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
  self.duplicateButton.adjustsImageWhenHighlighted = YES;
  [self.duplicateButton addTarget:self action:@selector(copyColor) forControlEvents:UIControlEventTouchUpInside];
  
  self.pasteButton = [UIButton buttonWithType:UIButtonTypeSystem];
  self.pasteButton.frame = CGRectMake(30, 0, 30, 40);
  [self.pasteButton setImage:self.pasteButtonImage forState:UIControlStateNormal];
  [self.pasteButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
  self.pasteButton.adjustsImageWhenHighlighted = YES;
  [self.pasteButton addTarget:self action:@selector(pasteColor) forControlEvents:UIControlEventTouchUpInside];
  
  [self.duplicatePasteView addSubview:self.duplicateButton];
  [self.duplicatePasteView addSubview:self.pasteButton];
  self.hexTextField.rightView = self.duplicatePasteView;
  self.hexTextField.rightViewMode = UITextFieldViewModeAlways;
  
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
  self.recentCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.recentCollectionView.topAnchor constraintEqualToAnchor:(self.modal.topView.topAnchor)].active = YES;
  CGFloat width = (NUM_RECENT_CELL * RECENT_CELL_SIZE.width) + (5.0f * (NUM_RECENT_CELL + 1));
  [self.recentCollectionView.widthAnchor constraintEqualToConstant:width].active = YES;
  [self.recentCollectionView.rightAnchor constraintEqualToAnchor:self.modal.topView.rightAnchor].active = YES;
//  [self.recentCollectionView.centerXAnchor constraintEqualToAnchor:self.modal.topView.centerXAnchor].active = YES;
  [self.recentCollectionView.centerYAnchor constraintEqualToAnchor:self.modal.topView.centerYAnchor].active = YES;
  
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
  [self.modal.topView addSubview:self.recentCollectionView];
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
    self.recentCollectionView.layer.borderColor = self.modal.secondaryColor.CGColor;

    self.previewColor.layer.borderColor = self.modal.secondaryColor.CGColor;
    
    self.hexTextField.backgroundColor = self.modal.secondaryColor;
    self.hexTextField.textColor = self.modal.secondaryTextColor;
    [[UITextField appearance] setTintColor:self.modal.secondaryTextColor];
    self.canEditMessage.textColor = self.modal.secondaryTextColor;
    self.canEditMessageBorder.borderColor = self.modal.secondaryTextColor.CGColor;
  } else if(self.lightUI) {
    self.scrollView.layer.borderColor = self.modal.secondaryColor.CGColor;
    self.recentCollectionView.layer.borderColor = self.modal.secondaryColor.CGColor;
    
    self.previewColor.layer.borderColor = self.modal.secondaryColor.CGColor;
    
    self.hexTextField.backgroundColor = self.modal.secondaryColor;
    self.hexTextField.textColor = self.modal.secondaryTextColor;
    [[UITextField appearance] setTintColor:self.modal.secondaryTextColor];
    self.canEditMessage.textColor = self.modal.secondaryTextColor;
    self.canEditMessageBorder.borderColor = self.modal.secondaryTextColor.CGColor;
  } else {
    self.scrollView.layer.borderColor = self.modal.primaryColor.CGColor;
    self.recentCollectionView.layer.borderColor = self.modal.primaryColor.CGColor;
    
    self.previewColor.layer.borderColor = self.modal.primaryColor.CGColor;
    
    self.hexTextField.backgroundColor = self.modal.primaryColor;
    self.hexTextField.textColor = self.modal.primaryTextColor;
    [[UITextField appearance] setTintColor:self.modal.primaryTextColor];
    self.canEditMessage.textColor = self.modal.primaryTextColor;
    self.canEditMessageBorder.borderColor = self.modal.primaryTextColor.CGColor;
  }
  
  self.duplicateButtonImage = [OBSUtilities newColor:self.hexTextField.textColor forImage:self.duplicateButtonImage];
  self.pasteButtonImage = [OBSUtilities newColor:self.hexTextField.textColor forImage:self.pasteButtonImage];
  
  [self.duplicateButton setImage:self.duplicateButtonImage forState:UIControlStateNormal];
  self.duplicateButton.tintColor = self.hexTextField.textColor;
  [self.pasteButton setImage:self.pasteButtonImage forState:UIControlStateNormal];
  self.pasteButton.tintColor = self.hexTextField.textColor;
}

#pragma mark COLOR MODIFIERS
- (void)setInitialColor:(UIColor *)color {
  [self updateToColor:color];
  [self grabRecentColorData];
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
  if(textField.text.length + string.length > 9) {
    [self shakeWrong];
  } else {
    if([OBSUtilities isValidHexColorLetter:string]) {
      if (textField.text.length == 0 && [string characterAtIndex:0] != '#') {
        textField.text = [NSString stringWithFormat:@"#%@", [string uppercaseString]];
      } else {
        textField.text = [textField.text stringByAppendingString:[string uppercaseString]];
      }
    } else {
      [self shakeWrong];
    }
  }
  
  if (string.length == 0 && range.length == 1) {
    return YES;
  }
  
  return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  if([OBSUtilities isValidHexColorString:textField.text]) {
    UIColor *color = [OBSUtilities colorFromHexString:self.hexTextField.text];
    [self updateToColor:color];
  } else {
    [self shakeWrong];
  }
  
  [textField resignFirstResponder];
  return YES;
}

- (void)shakeWrong {
  static const float offsetValue = 20.0f;
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
  [animation setDuration:0.05];
  [animation setRepeatCount:2];
  [animation setAutoreverses:YES];
  [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([self.modal center].x - offsetValue, [self.modal center].y)]];
  [animation setToValue:[NSValue valueWithCGPoint:CGPointMake([self.modal center].x + offsetValue, [self.modal center].y)]];
  [[self.modal layer] addAnimation:animation forKey:@"position"];
}

#pragma mark PICKER EXIT FUNCTIONS
- (void)selectButtonPressed {
  if (self.delegate) {
    if ([self.delegate respondsToSelector:@selector(colorPickerReturnedWithColor:andHexString:)]) {
      UIColor *color = [UIColor colorWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value alpha:self.alphaSlider.value];
      UIColor *lastRecentColor = [OBSUtilities colorFromHexString:self.recentColors.lastObject];
      NSString *lastRecentColorHex = [OBSUtilities hexStringFromColor:lastRecentColor];
      // if last recent color is not similar to the selected color than add it to the last spot in the recent color
      if(![lastRecentColorHex isEqualToString:self.hexTextField.text]) {
        [self.recentColors removeObjectAtIndex:0];
        [self.recentColors addObject:self.hexTextField.text];
      }
      
      // update Colors and save it to a file
      [self.recentColorDictionary setObject:self.recentColors forKey:@"Colors"];
      [self.recentColorDictionary writeToFile:ResourceRecentColorPath atomically:YES];
      
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

#pragma mark LOAD IMAGE FUNCTIONS
- (UIImage *)pasteImage {
  static UIImage *pasteIMG = nil;
  if(!pasteIMG) {
    NSData *data = [NSData dataWithContentsOfFile:[ResourcePath stringByAppendingString:@"/paste.png"]];
    pasteIMG = [data ? [UIImage imageWithData:data] : [UIImage imageNamed:@"paste"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  }
  
  return pasteIMG;
}

- (UIImage *)copyImage {
  static UIImage *copyIMG = nil;
  if(!copyIMG) {
    NSData *data = [NSData dataWithContentsOfFile:[ResourcePath stringByAppendingString:@"/copy.png"]];
    copyIMG = [data ? [UIImage imageWithData:data] : [UIImage imageNamed:@"copy"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  }
  
  return copyIMG;
}

#pragma mark COPY AND PASTE FUNCTIONS
- (void)copyColor {
  if([OBSUtilities isValidHexColorString:self.hexTextField.text]) {
    [[UIPasteboard generalPasteboard] setString:self.hexTextField.text];
  } else {
    [self shakeWrong];
  }
}

- (void)pasteColor {
  NSString *possibleHex = [[UIPasteboard generalPasteboard] string];
  if([OBSUtilities isValidHexColorString:possibleHex]) {
    [self updateToColor:[OBSUtilities colorFromHexString:possibleHex]];
  } else {
    [self shakeWrong];
  }
}
@end
