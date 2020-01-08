//
//  FBPerformanceCommands.m
//  WebDriverAgentLib
//
//  Created by cheney on 2019/4/14.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "FBPerformanceCommands.h"
#import "FBRouteRequest.h"
#import "FBRoute.h"
#import "FBApplication.h"
#import "XCUIElement+FBFind.h"
#import "XCEventGenerator.h"
#import "FBScreenHelper.h"

@implementation FBPerformanceCommands

+ (NSArray *)routes
{
  return
  @[
    [[FBRoute POST:@"/performance/launch"] respondWithTarget:self action:@selector(handleLaunchApp:)],
    [[FBRoute POST:@"/kill/app"] respondWithTarget:self action:@selector(killApp:)],
    [[FBRoute GET:@"/kill/currentApp"] respondWithTarget:self action:@selector(killCurrentApp:)],
    [[FBRoute GET:@"/stopserver"] respondWithTarget:self action:@selector(stopServer:)]
    ];
  
}

+ (id<FBResponsePayload>)stopServer:(FBRouteRequest *)request{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"stopServer" object:nil];
  return FBResponseWithOK();
}


+ (id<FBResponsePayload>)handleLaunchApp:(FBRouteRequest *)request
{
  // first to launch app
  NSString *bundleID = request.arguments[@"bundleId"];
  NSString *appName = request.arguments[@"appName"];
   BOOL needKill = request.arguments[@"needKill"];
  if (needKill) {
     [self launchAndKill:bundleID];
  }

  
  //click icon to launch app
  FBApplication *myapp = [FBApplication fb_activeApplication];
  NSArray *elements = [myapp fb_descendantsMatchingIdentifier:appName shouldReturnAfterFirstMatch:YES];
  if ([elements  count] == 1){
    XCUIElement *element = [elements objectAtIndex:0];
    if (element) {
      CGRect frame = element.frame;
      CGPoint point = CGPointMake(frame.origin.x,  frame.origin.y);
      [self tapApp:point withFrame:frame];
    }
      return FBResponseWithOK();
  }
  else{
      return FBResponseWithErrorFormat(@"launch app failed!!!");
  }
}

+(void)launchAndKill:(NSString *)bundleID{
  FBApplication *app = [[FBApplication alloc] initPrivateWithPath:nil bundleID:bundleID];
  [app launch];
  //kill the app
  [app terminate];
}

+ (id<FBResponsePayload>)killApp:(FBRouteRequest *)request{
    NSString *bundleID = request.arguments[@"bundleId"];
    FBApplication *myapp = [FBApplication fb_activeApplication];
  if ([myapp.bundleID isEqualToString:bundleID]) {
    [myapp terminate];
  }
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)killCurrentApp:(FBRouteRequest *)request{
    FBApplication *currentApp = [FBApplication fb_activeApplication];
  if ([currentApp.bundleID isEqualToString:@"com.apple.springboard"]) {
      return FBResponseWithOK();
  }
   [currentApp terminate];
   return FBResponseWithOK();
}

+(void)tapApp:(CGPoint)appPoint withFrame:(CGRect)frame{
  [self swipeToApp:appPoint];
  CGSize size = [FBScreenHelper screenSize];
  
  CGFloat x =(CGFloat) ((int)appPoint.x % (int)size.width);
  CGPoint point =  CGPointMake( x + frame.size.width / 2 , appPoint.y + frame.size.height / 2);
  [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  [[XCEventGenerator sharedGenerator]pressAtPoint:point forDuration:0.1 orientation:UIInterfaceOrientationUnknown handler:^(XCSynthesizedEventRecord *record, NSError *error) {
     dispatch_semaphore_signal(sem);
  }];
  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

+(void)swipeToApp:(CGPoint)appPoint {
    CGFloat x = appPoint.x;
    CGSize size = [FBScreenHelper screenSize];
  while (x < 0 || x > size.width) {
    if (x < 0) {
      [self swipeRight];
        x += size.width;
    }
    else{
      [self swipeLeft];
      x -= size.width;
    }
  }
}

+(void)swipeLeft{
  CGSize size = [FBScreenHelper screenSize];
  CGPoint startPoint = CGPointMake(size.width * 0.8, size.height * 0.5);
  CGPoint endPoint = CGPointMake(size.width * 0.2, size.height * 0.5);
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  [[XCEventGenerator sharedGenerator] pressAtPoint:startPoint forDuration:0 liftAtPoint:endPoint velocity: 5000  orientation:UIInterfaceOrientationUnknown name:nil handler:^(XCSynthesizedEventRecord *record, NSError *error) {
      dispatch_semaphore_signal(sem);
  }];
  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

+(void)swipeRight{
  CGSize size = [FBScreenHelper screenSize];
  CGPoint startPoint = CGPointMake(size.width * 0.2, size.height * 0.5);
  CGPoint endPoint = CGPointMake(size.width * 0.8, size.height * 0.5);
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  [[XCEventGenerator sharedGenerator] pressAtPoint:startPoint forDuration:0 liftAtPoint:endPoint velocity: 5000  orientation:UIInterfaceOrientationUnknown name:nil handler:^(XCSynthesizedEventRecord *record, NSError *error) {
    dispatch_semaphore_signal(sem);
  }];
  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

@end
