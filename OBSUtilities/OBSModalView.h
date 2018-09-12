//
//  OBSModalView.h
//
//  Created by Orangebananaspy on 2018-08-14.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OBSModalDelegate <NSObject>
@required
- (void)closeButtonPressed;
- (void)selectButtonPressed;
@end

/*
 Stores all the present options for OBSModalView to use
 - delegate must be set or crash will occur when buttons are pressed
 - select button title must also be set or a crash will occur when the title
   about to be set for the button
 */
@interface OBSModalOptions : NSObject
@property (nonatomic, assign) CGRect modalFrame;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, weak) id <OBSModalDelegate> delegate;
@property (nonatomic, assign) BOOL lightUI;
@property (nonatomic, strong) NSString *selectButtonTitle;
- (OBSModalOptions *)initWithModalFrame:(CGRect)frame cornerRadius:(CGFloat)radius delegate:(id <OBSModalDelegate>)modalDelegate isLightUI:(BOOL)light selectTitleForButton:(NSString *)title;
@end

@interface OBSModalView : UIView
/*
 View to add all other subviews to
 */
@property (nonatomic, strong, readonly) UIView *contentView;

/*
 Extra top view beside the close button
 */
@property (nonatomic, strong, readonly) UIView *topView;


/*
 If eclipse has been enabled for the settings app
 */
@property (nonatomic, assign, readonly) BOOL isEclipseEnabled;

/*
 Color scheme set according to light or dark UI (also affected by eclipse)
 */
@property (nonatomic, strong, readonly) UIColor *primaryColor;
@property (nonatomic, strong, readonly) UIColor *secondaryColor;
@property (nonatomic, strong, readonly) UIColor *primaryTextColor;
@property (nonatomic, strong, readonly) UIColor *secondaryTextColor;

- (OBSModalView *)initWithFrame:(CGRect)frame modalOptions:(OBSModalOptions *)options;
@end
