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

@implementation GtfCommands

#pragma mark - <FBCommandHandler>

+ (NSArray *)routes
{
  return
  @[
    [[FBRoute GET:@"/gtf/window/size"].withoutSession respondWithTarget:self action:@selector(handleWindowSize:)],
    [[FBRoute GET:@"/gtf/password/status"].withoutSession respondWithTarget:self action:@selector(handlePasswordStatus:)],
    [[FBRoute POST:@"/gtf/album/*"].withoutSession respondWithTarget:self action:@selector(handleAlbumAdd:)],
  ];
}

+ (id<FBResponsePayload>)handleWindowSize:(FBRouteRequest *)request
{
   return FBResponseWithStatus(FBCommandStatusNoError, @{
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
  if (![[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]]) {
    [FBLogger logFmt:@"Gtf add ablum failed! File not exist"];
    return FBResponseWithStatus(GtfCommandStatusAlbumFileNotExist, @{
      @"result": @"Add album failed! File not exist",
    });
  }
  
  if (!supportAlbumAccess()) {
    [FBLogger logFmt:@"Gtf add ablum failed! Ablum access not supported"];
    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
    return FBResponseWithStatus(GtfCommandStatusAlbumNotSupported, @{
      @"result": @"AddAablum failed! Ablum access not supported",
    });
  }
  
  if (!haveAlbumAuthorization()) {
    [FBLogger logFmt:@"Gtf add ablum failed! Ablum access unauthorized"];
    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
    return FBResponseWithStatus(GtfCommandStatusAlbumUnauthorized, @{
      @"result": @"Add ablum failed! Ablum access unauthorized",
    });
  }
  
  NSString *fileType = [fileName.pathExtension lowercaseString];
  BOOL isImage = [@[@"jpg", @"jpeg", @"png"] containsObject:fileType];
  BOOL isVideo = [@[@"mp4", @"mov"] containsObject:fileType];
  if (!isImage && !isVideo) {
    [FBLogger logFmt:@"Gtf add ablum failed! Unknown file type"];
    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
    return FBResponseWithStatus(GtfCommandStatusAlbumFileTypeUnknown, @{
      @"result": @"Add album failed! Unknown file type",
    });
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
    return FBResponseWithStatus(GtfCommandStatusAlbumChangeFailed, @{
      @"result": [NSString stringWithFormat:@"Add album failed! %@", error.description],
    });
  } else {
    [FBLogger logFmt:@"Gtf add ablum succeeded"];
    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:nil];
    return FBResponseWithStatus(FBCommandStatusNoError, @{
      @"result": @"Add album succeeded",
    });
  }
}

+ (id<FBResponsePayload>)handlePasswordStatus:(FBRouteRequest *)request {
  LAContext *myContext = [[LAContext alloc] init];
  if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil]) {
    return FBResponseWithStatus(FBCommandStatusNoError, @YES);
  }
  else {
    return FBResponseWithStatus(FBCommandStatusNoError, @NO);
  }
}

@end
