//
//  FBRemoteCommands.m
//  WebDriverAgentLib
//
//  Created by cheney on 2019/4/10.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "FBRemoteCommands.h"
#import "FBAlert.h"
#import "FBApplication.h"
#import "FBRouteRequest.h"
#import "FBSession.h"
#import "FBConfiguration.h"
#import "FBLogger.h"

@implementation FBRemoteCommands

+ (NSArray *)routes
{
  return
  @[
     [[FBRoute GET:@"/rcontrol/stop"] respondWithTarget:self action:@selector(handleRemoteControlStop:)],
    [[FBRoute POST:@"/rcontrol/ajustFrameRate"] respondWithTarget:self action:@selector(handleAjustFrameRate:)]
    ];
}

+ (id<FBResponsePayload>)handleRemoteControlStop:(FBRouteRequest *)request
{
  [self stopRemoteControl];
    return FBResponseWithOK();
}

+(id<FBResponsePayload>)stopRemoteControl{
  [[NSNotificationCenter defaultCenter] postNotificationName:@"Stop_Remote_Control_Notification" object:nil];
  return FBResponseWithOK();
}

+(id<FBResponsePayload>)handleAjustFrameRate:(FBRouteRequest*)request{
   NSInteger framerate = (NSInteger)[request.arguments[@"framerate"] integerValue];
  if (framerate > 60) {
    return FBResponseWithErrorFormat(@"Your input framerate: %d great than 60", framerate);
  }
  if (framerate <= 0) {
    return FBResponseWithErrorFormat(@"Your input framerate: %d less than 1",framerate);
  }
   [FBConfiguration setMjpegServerFramerate:framerate];
  return FBResponseWithOK();
}

@end
