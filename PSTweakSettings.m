//
//  PSTweakSettings.m
//
//  Created by Orangebananaspy on 2018-08-08.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import "PSTweakSettings.h"

#define tweakPreferencePath @"/var/mobile/Library/Preferences/"

@interface PSTweakSettings ()
@property (nonatomic, strong) NSString *currentUser;
@property (nonatomic, strong) NSString *plistPath;
@property (nonatomic, strong) NSMutableDictionary *tweakSettings;
- (void)checkUser:(NSString *)user withPlistName:(NSString *)plistName;
@end

@implementation PSTweakSettings
+ (PSTweakSettings *)instanceWithName:(NSString *)plistName andUser:(NSString *)user {
  static PSTweakSettings *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  
  [instance checkUser:user withPlistName:plistName];
  return instance;
}

- (void)checkUser:(NSString *)user withPlistName:(NSString *)plistName {
  if(self.currentUser != user) {
    self.tweakSettings = nil;
    self.plistPath = [NSString stringWithFormat:@"%@%@", tweakPreferencePath, plistName];
    if(!(self.tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:self.plistPath])) {
      self.tweakSettings = [NSMutableDictionary dictionary];
    }
    
    self.currentUser = user;
  }
}

- (id)getSettingsForKey:(id)key {
  return self.tweakSettings[key];
}

- (void)updateSettingsForKey:(id)key andValue:(id)value {
  self.tweakSettings[key] = value;
  [self saveSettings];
}

- (void)saveSettings {
  [self.tweakSettings writeToFile:self.plistPath atomically:YES];
}
@end
