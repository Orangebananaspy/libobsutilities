//
//  TweakSettings.m
//
//  Created by Orangebananaspy on 2018-08-24.
//  Copyright © 2018 Orangebananaspy. All rights reserved.
//

#import "OBSUtilities/TweakSettings.h"

#define tweakPreferencePath @"/var/mobile/Library/Preferences/"

@interface TweakSettings ()
@property (nonatomic, strong) NSMutableDictionary *settingsCache;
@property (nonatomic, strong) NSLock *cacheLock; /* This will make it thread safe */
@end

/*
 TODO: Cleanup cache (possible techniques)
  - remove dictionary after x seconds if not used
  - rely on resprings to refresh the list of cache
 */
@implementation TweakSettings
+ (TweakSettings *)instanceWithFileName:(NSString *)plistName andTweakID:(NSString *)t_id; {
  static TweakSettings *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[super alloc] init];
  });
  
  // if instance has been successfully allocated
  if(instance) {
    // initiate settings cache if not already
    if(!instance.settingsCache) {
      instance.settingsCache = [NSMutableDictionary dictionary];
    }
    
    // initiate cache lock if not already
    if(!instance.cacheLock) {
      instance.cacheLock = [NSLock new];
    }
    
    // acquire cache lock
    [instance.cacheLock lock];
    
    // create user dictionary
    if(!instance.settingsCache[t_id]) {
      NSMutableDictionary *tweakSettings;
      // create plist path with the given plistName
      NSString *plistPath = [NSString stringWithFormat:@"%@%@", tweakPreferencePath, plistName];
      // if the file exists get it as a dictionary otherwise create an empty dictionary
      if(!(tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath])) {
        tweakSettings = [NSMutableDictionary dictionary];
      }
      
      // create the user dictionary with setup [user = [[settings = tweak settings], [plistpath = the path to the file]]]
      NSMutableDictionary *settings = [NSMutableDictionary dictionary];
      [settings setValue:tweakSettings forKey:@"settings"];
      [settings setValue:plistName forKey:@"plistpath"];
      
      [instance.settingsCache setValue:settings forKey:t_id];
    }
    
    // release cache lock
    [instance.cacheLock unlock];
  }
  
  return instance;
}

- (id)objectForKey:(id)key tweakID:(NSString *)t_id {
  id value = nil;
  
  // acquire cache lock
  [self.cacheLock lock];
  
  // if dictionary for user exists otherwise returns a nil
  if(self.settingsCache[t_id]) {
    // get the settings for the user and get its value for the given key
    NSMutableDictionary *tweakSettings = self.settingsCache[t_id][@"settings"];
    value = [tweakSettings objectForKey:key];
  }
  
  // release cache lock
  [self.cacheLock unlock];
  
  return value;
}

- (void)setObject:(id)object forKey:(id)key tweakID:(NSString *)t_id {
  // acquire cache lock
  [self.cacheLock lock];
  
  // if dictionary for user exists
  if(self.settingsCache[t_id]) {
    // get the settings for the user and get its value for the given key
    NSMutableDictionary *tweakSettings = self.settingsCache[t_id][@"settings"];
    [tweakSettings setObject:object forKey:key];
    
    // save the settings after modification
    [tweakSettings writeToFile:self.settingsCache[t_id][@"plistpath"] atomically:YES];
  }
  
  // release cache lock
  [self.cacheLock unlock];
}
@end
