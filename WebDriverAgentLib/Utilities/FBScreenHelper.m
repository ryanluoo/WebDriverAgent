//
//  FBScreenHelper.m
//  WebDriverAgentLib
//
//  Created by cheney on 2019/4/10.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "FBScreenHelper.h"
#import <sys/utsname.h>

@implementation FBScreenHelper

+ (BOOL)model:(NSString *)model inArray:(NSArray *)array{
  for (NSString *obj in array) {
    if ([obj isEqualToString:model]) {
      return YES;
    }
  }
  
  return NO;
}

+ (CGSize)screenSize{
  struct utsname systemInfo;
  uname(&systemInfo);
  NSString *model =  [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
  
  if ([self model:model inArray:@[@"iPhone3,1", @"iPhone3,2", @"iPhone4,1"]]) {
    return CGSizeMake(320, 480);
  }
  if ([self model:model inArray:@[@"iPhone5,1", @"iPhone5,2", @"iPhone5,3", @"iPhone5,4", @"iPhone6,1", @"iPhone6,2", @"iPhone8,4"]]) {
    return CGSizeMake(320, 568);
  }
  if ([self model:model inArray:@[@"iPhone7,2", @"iPhone8,1", @"iPhone9,1", @"iPhone9,3", @"iPhone10,1", @"iPhone10,4"]]) {
    return CGSizeMake(375, 667);
  }
  if ([self model:model inArray:@[@"iPhone7,1", @"iPhone8,2", @"iPhone9,2", @"iPhone9,4", @"iPhone10,2", @"iPhone10,5"]]) {
    return CGSizeMake(414, 736);
  }
  if ([self model:model inArray:@[@"iPhone10,3", @"iPhone10,6", @"iPhone11,2"]]) {
    return CGSizeMake(375, 812);
  }
  if ([self model:model inArray:@[@"iPhone11,8"]]) {
    return CGSizeMake(413, 896);
  }
  if ([self model:model inArray:@[@"iPhone11,6"]]) {
    return CGSizeMake(414, 896);
  }
  if ([self model:model inArray:@[@"iPad6,7"]]) {
    return CGSizeMake(1024, 1366);
  }
  return CGSizeZero;
}

+ (CGRect)screenRect{
  CGSize size = [self screenSize];
  return CGRectMake(0, 0, size.width, size.height);
}

@end
