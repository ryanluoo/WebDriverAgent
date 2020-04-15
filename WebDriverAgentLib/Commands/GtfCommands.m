//
//  GtfCommands.m
//  WebDriverAgentLib
//
//  Created by ryan on 2020/2/25.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "GtfCommands.h"
#import "FBLogger.h"
#import "FBRouteRequest.h"
#import "FBApplication.h"
#import <XCTest/XCUIDevice.h>
#import <Photos/Photos.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "FBCommandStatus+GTF.h"

@implementation GtfCommands

#pragma mark - <FBCommandHandler>

+ (NSArray *)routes
{
  return
  @[
    [[FBRoute GET:@"/gtf/window/size"].withoutSession respondWithTarget:self action:@selector(handleWindowSize:)],
    [[FBRoute GET:@"/gtf/password/status"].withoutSession respondWithTarget:self action:@selector(handlePasswordStatus:)],
    [[FBRoute POST:@"/gtf/album/*"].withoutSession respondWithTarget:self action:@selector(handleAlbumAdd:)],
    [[FBRoute DELETE:@"/gtf/app/*"].withoutSession respondWithTarget:self action:@selector(killApp:)],
  ];
}

+ (id<FBResponsePayload>)handleWindowSize:(FBRouteRequest *)request
{
   return FBResponseWithObject(@{
     @"width": @([[UIScreen mainScreen] bounds].size.width),
     @"height": @([[UIScreen mainScreen] bounds].size.height),
   });
}

BOOL supportAlbumAccess() {
  NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
  NSMutableDictionary *infoDict = [NSMutableDictionary dictionaryWithContentsOfFile:bundlePath];
  if ([infoDict objectForKey:@"NSPhotoLibraryUsageDescription"]) {
    return YES;
  } else {
    return NO;
  }
}

BOOL haveAlbumAuthorization() {
  PHAuthorizationStatus currentStatus = [PHPhotoLibrary authorizationStatus];
  if (currentStatus == PHAuthorizationStatusNotDetermined) {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    }];
  }
  
  if (currentStatus == PHAuthorizationStatusNotDetermined ||
      currentStatus == PHAuthorizationStatusRestricted ||
      currentStatus == PHAuthorizationStatusDenied) {
    return NO;
  } else {
    return YES;
  }
}

+ (id<FBResponsePayload>)handleAlbumAdd:(FBRouteRequest *)request
{
  NSString *fileName = request.URL.lastPathComponent;
  [FBLogger logFmt:@"Gtf adding file to ablbum: %@", fileName];
  NSURL *fileUrl = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:fileName];
  if (![[NSFileManager defaultManager] fileExistsAtPath:(NSString * _Nonnull)[fileUrl path]]) {
    [FBLogger logFmt:@"Gtf add ablum failed! File not exist"];
    return FBResponseWithStatus([FBCommandStatus fileNotExistErrorWithMessage:nil
                                                                    traceback:nil]);
  }
  
  if (!supportAlbumAccess()) {
    [FBLogger logFmt:@"Gtf add ablum failed! Ablum access not supported"];
    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
    return FBResponseWithStatus([FBCommandStatus incompatibleErrorWithMessage:nil
                                                                    traceback:nil]);
  }
  
  if (!haveAlbumAuthorization()) {
    [FBLogger logFmt:@"Gtf add ablum failed! Ablum access unauthorized"];
    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
    return FBResponseWithStatus([FBCommandStatus unauthorizedErrorWithMessage:nil
                                                                    traceback:nil]);
  }
  
  NSString *fileType = [fileName.pathExtension lowercaseString];
  BOOL isImage = [@[@"jpg", @"jpeg", @"png"] containsObject:fileType];
  BOOL isVideo = [@[@"mp4", @"mov"] containsObject:fileType];
  if (!isImage && !isVideo) {
    [FBLogger logFmt:@"Gtf add ablum failed! Unknown file type"];
    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
    return FBResponseWithStatus([FBCommandStatus unknownMediaTypeErrorWithMessage:[NSString stringWithFormat:@"unknown media type: %@", fileType]
                                                                        traceback:nil]);
  }
  
  NSError *error = nil;
  [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
    if (isImage) {
      [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:fileUrl];
    } else if (isVideo) {
      [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileUrl];
    }
  } error:&error];
  
  if (error != nil) {
    [FBLogger logFmt:@"Gtf add ablum failed! %@", error.description];
    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
    return FBResponseWithUnknownError(error);
  } else {
    [FBLogger logFmt:@"Gtf add ablum succeeded"];
    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
    return FBResponseWithOK();
  }
}

+ (id<FBResponsePayload>)handlePasswordStatus:(FBRouteRequest *)request {
  LAContext *myContext = [[LAContext alloc] init];
  if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil]) {
    return FBResponseWithObject(@YES);
  }
  else {
    return FBResponseWithObject(@NO);
  }
}

+ (id<FBResponsePayload>)killApp:(FBRouteRequest *)request{
  NSString *bundleId = request.URL.lastPathComponent;
  [FBLogger logFmt:@"Kill app with bundle id: %@", bundleId];
  FBApplication *targetApp = nil;
  if ([bundleId isEqualToString:@"current"]) {
    FBApplication *currentApp = FBApplication.fb_activeApplication;
    if (![currentApp.bundleID isEqualToString:@"com.apple.springboard"]) {
      targetApp = currentApp;
    }
  } else {
    targetApp = [[FBApplication alloc] initWithBundleIdentifier:bundleId];
  }
  
  if (targetApp) {
    [targetApp terminate];
  }
  return FBResponseWithOK();
}

@end
