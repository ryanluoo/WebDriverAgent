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

@implementation GtfCommands

#pragma mark - <FBCommandHandler>

+ (NSArray *)routes
{
  return
  @[
    [[FBRoute GET:@"/gtf/window/size"].withoutSession respondWithTarget:self action:@selector(handleWindowSize:)],
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
  if (!supportAlbumAccess()) {
   [FBLogger logFmt:@"Gtf add ablum failed! Ablum access not supported"];
    return FBResponseWithStatus(FBCommandStatusUnsupported, @{
      @"result": @"AddAablum failed! Ablum access not supported",
    });
  }
  
  if (!haveAlbumAuthorization()) {
    [FBLogger logFmt:@"Gtf add ablum failed! Ablum access denied. Need to authorize WDA first"];
    return FBResponseWithStatus(FBCommandStatusMethodNotAllowed, @{
      @"result": @"Add ablum failed! Ablum access denied. Need to authorize WDA first",
    });
  }
  
  NSString *fileName = request.URL.lastPathComponent;

  [FBLogger logFmt:@"Gtf adding file to ablbum: %@", fileName];
  NSURL *fileUrl = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:fileName];
  if (![[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]]) {
    [FBLogger logFmt:@"Gtf add ablum failed! File not exist"];
    return FBResponseWithStatus(FBCommandStatusInvalidArgument, @{
      @"result": @"Add album failed! File not exist",
    });
  }
  
  NSString *fileType = [fileName.pathExtension lowercaseString];
  BOOL isImage = [@[@"jpg", @"jpeg", @"png"] containsObject:fileType];
  BOOL isVideo = [@[@"mp4", @"mov"] containsObject:fileType];
  if (!isImage && !isVideo) {
    [FBLogger logFmt:@"Gtf add ablum failed! Unsupported file type"];
    return FBResponseWithStatus(FBCommandStatusInvalidArgument, @{
      @"result": @"Add album failed! Unsupported file type",
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
    return FBResponseWithStatus(FBCommandStatusInvalidArgument, @{
      @"result": [NSString stringWithFormat:@"Add album failed! %@", error.description],
    });
  } else {
    [FBLogger logFmt:@"Gtf add ablum succeeded"];
    return FBResponseWithStatus(FBCommandStatusNoError, @{
      @"result": @"Add album succeeded",
    });
  }
}

@end
