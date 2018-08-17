//
//  OBSUtilities.h
//
//  Created by Orangebananaspy on 2018-07-28.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef OBSUtilities_h
#define OBSUtilities_h

typedef enum Edge : NSUInteger {
  kTop,
  kLeft,
  kRight,
  kBottom
} Edge;

@interface OBSUtilities : NSObject
/*
 Gets the average color from the given image. It draws the entire image in a 1x1 pixel with
 medium interpolation which is forcing the colors to merge and the result is the average color of the
 given image. This technique is used in https://github.com/NikolaiRuhe/UIImageAverageColor for testing
 a common averaging method with this one, and it is about 4 times faster.
 */
+ (UIColor *)averageColorForImage:(UIImage *)image;

/*
 Gets the color from the given hex string. If the format is invalid it returns black as the color if
 not explicity already specified to be black.
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;

/*
 True if the letter is a valid hex color letter, otherwise false. You can also send in multiple
 letters in the string. Although this only checks if all the letters in the string are valid, it
 does not guarantee that it is a valid hex color string.
 */
+ (BOOL)isValidHexColorLetter:(NSString *)hexLetter;

/*
 True if the hexString is a valid hex color string which will produce a valid color.
 */
+ (BOOL)isValidHexColorString:(NSString *)hexString;

/*
 Gets the hex color corresponding to the given color.
 */
+ (NSString *)hexStringFromColor:(UIColor *)color;

/*
 True if the color is bright, otherwise false. This is particularly useful if you want to check if the
 background is dark or bright so you can have adaptive colored text.
 */
+ (BOOL)isColorBright:(UIColor *)color;

/*
 Inverses the given color. It is useful mostly to inverse a text color so it can adapt to various
 colored background.
 */
+ (UIColor *)inverseColor:(UIColor *)color;

/*
 It returns a dictionary with Background, Primary, or Secondary colors for the given image.
 Format of dicionary {@"Background" : UIColor, @"Primary" : UIColor, @"Secondary" : UIColor}
 
 Please note that the edge will be the background color, it simply determines the key side
 of the image you actually care about and very useful for instances where if a badge is placed
 on the top side of the image, then you care more about the top edge
 */
+ (NSDictionary *)colorsFromImage:(UIImage *)image withEdge:(Edge)edge;

/*
 Check if the two given colors are similar by the given tolerance.
 */
+ (BOOL)isColor:(UIColor *)aColor similarToColor:(UIColor *)bColor tolerance:(float)tolerance;

/*
 Returns a 1x1 pixel UIImage with the given color.
 */
+ (UIImage *)imagePixelFromColor:(UIColor *)color;

/*
 Returns an image of specified size with the given color.
 */
+ (UIImage *)imageFromColor:(UIColor *)color withSize:(CGSize)size;

/*
 Changes the color of the given image by the given color.
 */
+ (UIImage *)newColor:(UIColor *)color forImage:(UIImage *)image;

/*
 Changes the scale of the given image by the given scale.
 */
+ (UIImage *)newScale:(CGSize)newSize forImage:(UIImage *)image;
@end
#endif /* OBSUtilities_h */
