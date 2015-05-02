//
//  SimpleNetworking.m
//  SimpleNetworkingExample
//
//  Created by Bibo on 4/22/15.
//  Copyright (c) 2015 Bibo. All rights reserved.
//

#import "SimpleNetworking.h"

@implementation SimpleNetworking

@synthesize headerFields;

+ (SimpleNetworking *)shared {
    static SimpleNetworking *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ shared = [[[self class] alloc] init]; });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        headerFields = [NSDictionary new];
        [SimpleNetworking setCacheSizeMemoryCapacityInMB:16 diskCapacity:32];
        //default, will be overwritten if setCacheSizeMemoryCapacityInMB is set in your project
    }
    return self;
}

+ (void)setCacheSizeMemoryCapacityInMB:(int)memoryCapacityInMB diskCapacity:(int)diskCapacityInMB {
    int memoryCapacity = memoryCapacityInMB*1024*1024;
    int diskCapacity = diskCapacityInMB*1024*1024;
    [NSURLCache setSharedURLCache:[[NSURLCache alloc]initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:nil]];
}

+ (void)getJsonFromURL:(NSString *)urlString param:(NSDictionary *)param cachePolicy:(NSURLRequestCachePolicy)cachePolicy cacheTimeout:(NSTimeInterval)interval returned:(void (^)(id responseObject, NSError *error))callback {
    [[self shared] NSURLConnectionSendAsynchronousRequestWithType:@"GET" url:urlString param:param isImage:NO cachePolicy:cachePolicy cacheTimeout:interval imageInNSData:nil returned:^(id responseObject, NSError *error) {
        callback (responseObject, error);
    }];
}

+ (void)getJsonCachelessFromURL:(NSString *)urlString param:(NSDictionary *)param returned:(void (^)(id responseObject, NSError *error))callback {
    [[self shared] NSURLConnectionSendAsynchronousRequestWithType:@"GET" url:urlString param:param isImage:NO cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData cacheTimeout:0 imageInNSData:nil returned:^(id responseObject, NSError *error) {
        callback (responseObject, error);
    }];
}

+ (void)getImageFromURL:(NSString *)urlString param:(NSDictionary *)param cachePolicy:(NSURLRequestCachePolicy)cachePolicy cacheTimeout:(NSTimeInterval)interval returned:(void (^)(UIImage *responseImage, NSError *error))callback {
    [[self shared] NSURLConnectionSendAsynchronousRequestWithType:@"GET" url:urlString param:param isImage:YES cachePolicy:cachePolicy cacheTimeout:interval imageInNSData:nil returned:^(id responseObject, NSError *error) {
        UIImage *image = responseObject;
        callback (image, error);
    }];
}

+ (void)getImageCachelessFromURL:(NSString *)urlString param:(NSDictionary *)param returned:(void (^)(UIImage *responseImage, NSError *error))callback {
    [[self shared] NSURLConnectionSendAsynchronousRequestWithType:@"GET" url:urlString param:param isImage:YES cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData cacheTimeout:0 imageInNSData:nil returned:^(id responseObject, NSError *error) {
        UIImage *image = responseObject;
        callback (image, error);
    }];
}

+ (void)postJsonToURL:(NSString *)urlString param:(NSDictionary *)param returned:(void (^)(id responseObject, NSError *error))callback {
    [[self shared] NSURLConnectionSendAsynchronousRequestWithType:@"POST" url:urlString param:param isImage:NO cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData cacheTimeout:0 imageInNSData:nil returned:^(id responseObject, NSError *error) {
        callback (responseObject, error);
    }];
}

+ (void)postImageToURL:(NSString *)urlString param:(NSDictionary *)param imageInNSData:(NSData *)imageInNSData imageName:(NSString *)imageName imageExtension:(NSString *)imageExtension returned:(void (^)(id responseObject, NSError *error))callback {
    [self shared].imageName = imageName;
    [self shared].imageExtension = imageExtension;
    [[self shared] NSURLConnectionSendAsynchronousRequestWithType:@"POST" url:urlString param:param isImage:YES cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData cacheTimeout:0 imageInNSData:imageInNSData returned:^(id responseObject, NSError *error) {
        callback (responseObject, error);
    }];
}

+ (void)putJsonToURL:(NSString *)urlString param:(NSDictionary *)param returned:(void (^)(id responseObject, NSError *error))callback {
    [[self shared] NSURLConnectionSendAsynchronousRequestWithType:@"PUT" url:urlString param:param isImage:NO cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData cacheTimeout:0 imageInNSData:nil returned:^(id responseObject, NSError *error) {
        callback (responseObject, error);
    }];
}

+ (void)deleteJsonFromURL:(NSString *)urlString param:(NSDictionary *)param returned:(void (^)(id responseObject, NSError *error))callback {
    [[self shared] NSURLConnectionSendAsynchronousRequestWithType:@"DELETE" url:urlString param:param isImage:NO cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData cacheTimeout:0 imageInNSData:nil returned:^(id responseObject, NSError *error) {
        callback (responseObject, error);
    }];
}

-(void)NSURLConnectionSendAsynchronousRequestWithType:(NSString *)type url:(NSString *)url param:(NSDictionary *)param isImage:(BOOL)isImage cachePolicy:(NSURLRequestCachePolicy)cachePolicy cacheTimeout:(NSTimeInterval)interval imageInNSData:(NSData *)imageInNSData returned:(void (^)(id responseObject, NSError *error))callback {
    
    if (_allowWorkingOffline) {
        cachePolicy = NSURLRequestReturnCacheDataDontLoad;
    }
    
    NSString *urlString = [self formattedUrlStringWithURL:url param:param isImage:isImage type:type];
    NSMutableURLRequest *urlRequest = [self addToURLRequestWithURLString:urlString Type:type param:param cachePolicy:cachePolicy cacheTimeout:interval imageInNSData:imageInNSData isImage:isImage];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    if ([type isEqualToString:@"GET"]) {
        sessionConfig.requestCachePolicy = cachePolicy;
        sessionConfig.URLCache = [NSURLCache sharedURLCache];
    }
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:queue];
    __block NSCachedURLResponse *cachedURLResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:urlRequest];
    __block NSData *responseData;
    
    if (cachePolicy == NSURLRequestReturnCacheDataElseLoad) {
        if(cachedURLResponse && cachedURLResponse != (id)[NSNull null]) {
            responseData = [cachedURLResponse data];
            if (isImage) {
                if ([type isEqualToString:@"GET"]) {
                    callback([UIImage imageWithData:responseData], nil);
                    return;
                }
            }
            NSError* error2;
            callback([NSJSONSerialization JSONObjectWithData:responseData
                                                     options:kNilOptions
                                                       error:&error2],nil);
        }
        else {
            NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (error) {
                        callback(nil, error);
                    }
                    else {
                        cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
                        [[NSURLCache sharedURLCache] storeCachedResponse:cachedURLResponse forRequest:urlRequest];
                    }
                    
                    if (isImage) {
                        if ([type isEqualToString:@"GET"]) {
                            callback([UIImage imageWithData:data], nil);
                            return;
                        }
                    }
                    NSError* error2;
                    callback([NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error2],nil);
                });
            }];
            [dataTask resume];
        }
    }
    else {
        [[NSURLCache sharedURLCache]removeCachedResponseForRequest:urlRequest];
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (error) {
                    callback(nil, error);
                }
                if (isImage) {
                    if ([type isEqualToString:@"GET"]) {
                        callback([UIImage imageWithData:data], nil);
                        return;
                    }
                }
                NSError* error2;
                callback([NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error2],nil);
            });
        }];
        [dataTask resume];
    }
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

-(NSString *)formattedUrlStringWithURL:(NSString *)url param:(NSDictionary *)param isImage:(BOOL)isImage type:(NSString *)type {
    NSString *urlString = url;
    if (param && isImage && [type isEqualToString:@"POST"]) {
        urlString = [NSString stringWithFormat:@"%@?%@", url, [self getParamInString:param]];
    }
    return urlString;
}

-(NSMutableURLRequest *)addToURLRequestWithURLString:(NSString *)urlString Type:(NSString *)type param:(NSDictionary *)param cachePolicy:(NSURLRequestCachePolicy)cachePolicy cacheTimeout:(NSTimeInterval)interval imageInNSData:(NSData *)imageInNSData isImage:(BOOL)isImage{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [urlRequest setHTTPMethod:type];
    if ([type isEqualToString:@"GET"]) {
        [urlRequest setCachePolicy:cachePolicy];
        [urlRequest setTimeoutInterval:interval];
    }
    
    if ([type isEqualToString:@"PUT"]) {
        [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
    
    if (headerFields.allKeys.count > 0) {
        for (int i = 0; i < (int)headerFields.allKeys.count; i++) {
            [urlRequest setValue:headerFields.allValues[i] forHTTPHeaderField:headerFields.allKeys[i]];
        }
    }
    
    NSMutableData *jsonData = [NSMutableData data];
    
    if (isImage && [type isEqualToString:@"POST"]) {
        NSString *boundary = @"uniqueSimpleNetworkingBoundary";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [urlRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        [jsonData appendData:[NSJSONSerialization dataWithJSONObject:@{@"":@""} options:0 error:nil]];
        
        [jsonData appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSASCIIStringEncoding]];
        [jsonData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [jsonData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.%@\"\r\n", self.imageName, self.imageExtension] dataUsingEncoding:NSUTF8StringEncoding]];
        [jsonData appendData:[[NSString stringWithFormat:@"Content-Type: image/%@\r\n\r\n",self.imageExtension] dataUsingEncoding:NSUTF8StringEncoding]];
        [jsonData appendData:imageInNSData];
        [jsonData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [jsonData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else {
        if (param) {
            [jsonData appendData:[[self getParamInString:param] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    urlRequest.HTTPBody = jsonData;
    return urlRequest;
}

-(NSString *)getParamInString:(NSDictionary *)param {
    NSMutableArray *parts = [NSMutableArray array];
    [param enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj != [NSNull null]) {
            [parts addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
        }
    }];
    NSString *addString = [parts componentsJoinedByString:@"&"];
    return addString;
}

@end
