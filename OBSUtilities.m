//
//  OBSUtilities.m
//
//  Created by Orangebananaspy on 2018-07-28.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import "OBSUtilities/OBSUtilities.h"
@import Accelerate;
#import <float.h>

#define Mask8(x) ((x) & 0xFF)
#define R(x) (Mask8(x))
#define G(x) (Mask8(x >> 8))
#define B(x) (Mask8(x >> 16))
#define A(x) (Mask8(x >> 24))
#define C(x) (x * 255.0)

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

+ (UIColor *)inverseColor:(UIColor *)color {
  CGFloat r,g,b,a;
  [color getRed:&r green:&g blue:&b alpha:&a];
  return [UIColor colorWithRed:1.-r green:1.-g blue:1.-b alpha:a];
}

// original can be found at https://stackoverflow.com/questions/13694618/objective-c-getting-least-used-and-most-used-color-in-a-image
// it has been modified to be more accurate, and ignore transparent colors
+ (NSArray *)colorsFromImage:(UIImage *)image {
  const float filterRange = 60;
  
  CGImageRef inputCGImage = [image CGImage];
  NSUInteger width = CGImageGetWidth(inputCGImage);
  NSUInteger height = CGImageGetHeight(inputCGImage);
  
  NSUInteger bytesPerPixel = 4;
  NSUInteger bytesPerRow = bytesPerPixel * width;
  NSUInteger bitsPerComponent = 8;
  
  UInt32 * pixels;
  pixels = (UInt32 *) calloc(height * width, sizeof(UInt32));
  
  // get the raw data
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputCGImage);
  CGColorSpaceRelease(colorSpace);
  CGContextRelease(context);
  
  // store non-transparent or non-alpha affected colors into an array
  NSMutableArray *colors = [NSMutableArray new];
  UInt32 * currentPixel = pixels;
  for (NSUInteger j = 0; j < height; j++) {
    for (NSUInteger i = 0; i < width; i++) {
      UInt32 color = *currentPixel;
      
      if(A(color) == 255) {
        UIColor *colorObject = [UIColor colorWithRed:(R(color) / 255.0f) green:(G(color) / 255.0f) blue:(B(color) / 255.0f) alpha:(A(color) / 255.0f)];
        [colors addObject:colorObject];
      }
      
      currentPixel++;
    }
  }
  free(pixels);
  
  // count occurence of colors and sort from high to low
  NSCountedSet *colorsCountedSet = [[NSCountedSet alloc] initWithArray:colors];
  NSArray *distinctColors = [[colorsCountedSet allObjects] sortedArrayUsingFunction:countedSort context:(void *)colorsCountedSet];
  
  // filter colors that are similar (within range of that color by the defined amount)
  NSMutableArray *filteredColors = [NSMutableArray new];
  for (UIColor *color in distinctColors) {
    bool accepted = true;
    for (UIColor *filteredColor in filteredColors) {
      CGFloat fRed = 0, fGreen = 0, fBlue = 0, fAlpha = 0;
      [filteredColor getRed:&fRed green:&fGreen blue:&fBlue alpha:&fAlpha];
      int32_t fr = C(fRed), fg = C(fGreen), fb = C(fBlue);
      
      CGFloat cRed = 0, cGreen = 0, cBlue = 0, cAlpha = 0;
      [color getRed:&cRed green:&cGreen blue:&cBlue alpha:&cAlpha];
      int32_t cr = C(cRed), cg = C(cGreen), cb = C(cBlue);
      
      if(abs(cr - fr) <= filterRange && abs(cg - fg) <= filterRange && abs(cb - fb) <= filterRange) {
        accepted = false;
        break;
      }
    }
    
    if(accepted) [filteredColors addObject:color];
  }

  return [filteredColors copy];
}

// helps sort colors in -[OBSUtilities coloursFromImage:]
NSInteger countedSort(id obj1, id obj2, void *context) {
  NSCountedSet *countedSet = (__bridge NSCountedSet *) context;
  NSUInteger obj1Count = [countedSet countForObject:obj1];
  NSUInteger obj2Count = [countedSet countForObject:obj2];
  
  if (obj1Count > obj2Count) return NSOrderedAscending;
  else if (obj1Count < obj2Count) return NSOrderedDescending;
  return NSOrderedSame;
}

+ (BOOL)isColor:(UIColor *)aColor similarToColor:(UIColor *)bColor tolerance:(float)tolerance {
  CGFloat hue, saturation, brightness, alpha;
  [aColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
  
  CGFloat ahue, asaturation, abrightness, aalpha;
  [bColor getHue:&ahue saturation:&asaturation brightness:&abrightness alpha:&aalpha];
  
  if (fabs(brightness - abrightness) < tolerance) {
    if (brightness == 0) {
      return YES;
    }
    if (fabs(saturation - asaturation) < tolerance) {
      if (saturation == 0) {
        return YES;
      }
      if (fabs(hue - ahue) < tolerance * 360) {
        return YES;
      }
    }
  }
  
  return NO;
}
@end
