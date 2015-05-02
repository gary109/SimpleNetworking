//
//  SimpleNetworking.h
//  SimpleNetworkingExample
//
//  Created by Bibo on 4/22/15.
//  Copyright (c) 2015 Bibo. All rights reserved.
//

//  version 1.0

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SimpleNetworking : NSObject <NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, retain) NSDictionary *headerFields;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *imageExtension;
@property (nonatomic) BOOL allowWorkingOffline;

+ (SimpleNetworking *)shared;

+ (void)setCacheSizeMemoryCapacityInMB:(int)memoryCapacity diskCapacity:(int)diskCapacity;

+ (void)getJsonFromURL:(NSString *)urlString param:(NSDictionary *)param cachePolicy:(NSURLRequestCachePolicy)cachePolicy cacheTimeout:(NSTimeInterval)interval returned:(void (^)(id responseObject, NSError *error))callback;

+ (void)getJsonCachelessFromURL:(NSString *)urlString param:(NSDictionary *)param returned:(void (^)(id responseObject, NSError *error))callback;

+ (void)getImageFromURL:(NSString *)urlString param:(NSDictionary *)param cachePolicy:(NSURLRequestCachePolicy)cachePolicy cacheTimeout:(NSTimeInterval)interval returned:(void (^)(UIImage *responseImage, NSError *error))callback;

+ (void)getImageCachelessFromURL:(NSString *)urlString param:(NSDictionary *)param returned:(void (^)(UIImage *responseImage, NSError *error))callback;

+ (void)postJsonToURL:(NSString *)urlString param:(NSDictionary *)param returned:(void (^)(id responseObject, NSError *error))callback;

+ (void)postImageToURL:(NSString *)urlString param:(NSDictionary *)param imageInNSData:(NSData *)imageInNSData imageName:(NSString *)imageName imageExtension:(NSString *)imageExtension returned:(void (^)(id responseObject, NSError *error))callback;

+ (void)putJsonToURL:(NSString *)urlString param:(NSDictionary *)param returned:(void (^)(id responseObject, NSError *error))callback;

+ (void)deleteJsonFromURL:(NSString *)urlString param:(NSDictionary *)param returned:(void (^)(id responseObject, NSError *error))callback;

@end
