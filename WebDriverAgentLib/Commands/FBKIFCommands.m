//
//  FBKIFCommands.m
//  WebDriverAgentLib
//
//  Created by cheney on 2019/9/10.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "FBKIFCommands.h"
#import "FBRouteRequest.h"
#import "FBResponseJSONPayload.h"


@implementation FBKIFCommands
+ (NSArray *)routes
{
  return
  @[
    [[FBRoute POST:@"/kif/*"] respondWithTarget:self action:@selector(handleKifCommands:)]
  ];
}
   
    
+ (id<FBResponsePayload>)handleKifCommands:(FBRouteRequest *)myrequest{
  NSString *urlstring = [NSString stringWithFormat:@"http://localhost:9988/kif/%@", [myrequest parameters][@"wildcards"][0]];
    NSURL *url = [NSURL URLWithString:urlstring];
  NSDictionary *data = [[self class] requestKIFServer:url andParams:(NSDictionary*)[myrequest arguments]];
  return FBResponseWithKIFObject(data);
}


+(NSDictionary *)requestKIFServer:(NSURL *)url andParams:(NSDictionary *)params{
  
  __block NSDictionary * data = nil;
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  if (params) {
    NSData * requestData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:requestData];
  }
  [request setHTTPMethod:@"POST"];
  NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];

  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *response, NSError *error) {
    if (error) {
      data =  [NSDictionary dictionaryWithObjectsAndKeys:@(23), @"status", error.description, @"err", [NSNull null], @"value", nil];
    }
    else{
      data = [NSJSONSerialization JSONObjectWithData:taskData options:NSJSONReadingMutableContainers error:nil];
    }
    dispatch_semaphore_signal(semaphore);
  }];
  [dataTask resume];
  dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
  
  return data;
}

@end
