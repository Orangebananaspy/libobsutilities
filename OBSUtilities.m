//
//  OBSUtilities.m
//
//  Created by Orangebananaspy on 2018-07-28.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import "OBSUtilities.h"
@import Accelerate;
#import <float.h>

UInt32 intFromString(NSString *string) {
  UInt32 hex = 0;
  NSScanner *scanner = [NSScanner scannerWithString:string];
  if(string.length == 7 || string.length == 9) [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
  [scanner scanHexInt:(unsigned int *) &hex];
  return hex;
}

@implementation OBSUtilities
#pragma mark UICOLOR UTILITIES
// Taken from https://github.com/NikolaiRuhe/UIImageAverageColor
+ (UIColor *)averageColorForImage:(UIImage *)image {
  CGSize size = {1.0f, 1.0f};
  UIGraphicsBeginImageContext(size);
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);
  [image drawInRect:(CGRect){{0.0f, 0.0f}, size} blendMode:kCGBlendModeCopy alpha:1.0f];
  uint8_t *data = (uint8_t *) CGBitmapContextGetData(ctx);
  UIColor *color = [UIColor colorWithRed:(data[2] / 255.0f) green:(data[1] / 255.0f) blue:(data[0] / 255.0f) alpha:1.0f];
  UIGraphicsEndImageContext();
  return color;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
  CGFloat red = 0.0f, green = 0.0f, blue = 0.0f, alpha = 0.0f;
  
  if ([OBSUtilities isValidHexColorString:hexString]) {
    UInt32 hex = intFromString(hexString);
    if(hexString.length == 7 || hexString.length == 6) {
      red = (CGFloat)((hex & 0xff0000) >> 16) / 255.0;
      green = (CGFloat)((hex & 0xff00) >> 8) / 255.0;
      blue = (CGFloat)((hex & 0xff) >> 0) / 255.0;
      alpha = 1.0f;
    } else if(hexString.length == 9 || hexString.length == 8) {
      red = (CGFloat)((hex & 0xff000000) >> 24) / 255.0;
      green = (CGFloat)((hex & 0xff0000) >> 16) / 255.0;
      blue = (CGFloat)((hex & 0xff00) >> 8) / 255.0;
      alpha = (CGFloat)((hex & 0xff) >> 0) / 255.0;
    }
  }

  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (BOOL)isValidHexColorLetter:(NSString *)hexLetter {
  NSCharacterSet* nonHex = [[NSCharacterSet characterSetWithCharactersInString: @"#0123456789ABCDEFabcdef"] invertedSet];
  NSRange nonHexRange = [hexLetter rangeOfCharacterFromSet:nonHex];
  return nonHexRange.location == NSNotFound;
}

+ (BOOL)isValidHexColorString:(NSString *)hexString {
  return [OBSUtilities isValidHexColorLetter:hexString] && (hexString.length == 7 || hexString.length == 6 || hexString.length == 9 || hexString.length == 8);
}

+ (NSString *)hexStringFromColor:(UIColor *)color {
  const CGFloat *components = CGColorGetComponents(color.CGColor);
  CGFloat r = components[0];
  CGFloat g = components[1];
  CGFloat b = components[2];
  CGFloat a = components[3];
  NSString *hexString;

  if(a == 1.0f) {
    hexString = [NSString stringWithFormat:@"#%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
  } else {
    hexString = [NSString stringWithFormat:@"#%02X%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255), (int)(a * 255)];
  }

  return hexString;
}

+ (BOOL)isColorBright:(UIColor *)color {
  CGFloat colorBrightness = 0;
  CGColorSpaceRef colorSpace = CGColorGetColorSpace(color.CGColor);
  CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
  
  if(colorSpaceModel == kCGColorSpaceModelRGB){
    const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
    colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
  } else {
    [color getWhite:&colorBrightness alpha:0];
  }
  
  return (colorBrightness >= .5f);
}

#pragma mark UIIMAGE UTILITIES
+ (UIImage *)imagePixelFromColor:(UIColor *)color {
  return [OBSUtilities imageFromColor:color withSize:CGSizeMake(1.0f, 1.0f)];
}

+ (UIImage *)imageFromColor:(UIColor *)color withSize:(CGSize)size {
  CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
  UIGraphicsBeginImageContext(rect.size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetFillColorWithColor(context, [color CGColor]);
  CGContextFillRect(context, rect);
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

+ (UIImage *)newColor:(UIColor *)color forImage:(UIImage *)image {
  UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
  CGContextRef context = UIGraphicsGetCurrentContext();
  [color setFill];
  CGContextTranslateCTM(context, 0, image.size.height);
  CGContextScaleCTM(context, 1.0, -1.0);
  CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
  CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
  UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return coloredImg;
}

+ (UIImage *)newScale:(CGSize)newSize forImage:(UIImage *)image {
  UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
  [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}
@end
