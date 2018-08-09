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
 Creates a singleton instance of PSTweakSettings with the name of the plist file representing the settings of a tweak
 and the user (developer) that will be using it.
 */
+ (PSTweakSettings *)instanceWithName:(NSString *)plistName andUser:(NSString *)user;

/*
 Get the settings for the key.
 */
- (id)getSettingsForKey:(id)key;

/*
 Update the value for the given key.
 */
- (void)updateSettingsForKey:(id)key andValue:(id)value;
@end
#endif /* PSTweakSettings_h */
