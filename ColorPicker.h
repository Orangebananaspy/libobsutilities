//
//  ColorPicker.h
//
//  Created by Orangebananaspy on 2018-08-07.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef ColorPicker_h
#define ColorPicker_h

@protocol ColorPickerDelegate <NSObject>
@required
- (void)colorPickerReturnedWithColor:(UIColor *)color andHexString:(NSString *)hexString;
@end

@interface ColorPicker : UIViewController <UITextFieldDelegate>
/*
 The delegate that contains the required function for the protocol.
 */
@property (nonatomic, weak) id <ColorPickerDelegate> delegate;

/*
 The UI of the color picker is light or dark. True is light, otherwise dark.
 Default is light.
 */
@property (nonatomic) BOOL lightUI;

/*
 Set the initial color for the picker. It can be called again to set a different color.
 */
- (void)setInitialColor:(UIColor *)color;
@end
#endif /* ColorPicker_h */
