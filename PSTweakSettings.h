//
//  PSTweakSettings.h
//
//  Created by Orangebananaspy on 2018-08-08.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef PSTweakSettings_h
#define PSTweakSettings_h

@interface PSTweakSettings : NSObject
/*
 Creates a singleton instance of PSTweakSettings with the
 */
+ (PSTweakSettings *)instanceWithName:(NSString *)plistName andUser:(NSString *)user;
- (id)getSettingsForKey:(id)key;
- (void)updateSettingsForKey:(id)key andValue:(id)value;
@end
#endif /* PSTweakSettings_h */
