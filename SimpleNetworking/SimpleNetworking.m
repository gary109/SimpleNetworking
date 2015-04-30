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
    }
    return self;
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
    
    NSString *urlString = url;
    
    if (param && isImage && [type isEqualToString:@"POST"]) {
        urlString = [NSString stringWithFormat:@"%@?%@", url, [self getParamInString:param]];
    }
    
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
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         dispatch_sync(dispatch_get_main_queue(), ^{
             if (error) {
                 callback(nil, error);
             }
             else {
                 if (isImage) {
                     if ([type isEqualToString:@"GET"]) {
                         callback([UIImage imageWithData:data], nil);
                     }
                     else if ([type isEqualToString:@"POST"]) {
                         NSError* error2;
                         callback([NSJSONSerialization JSONObjectWithData:data
                                                                  options:kNilOptions
                                                                    error:&error2],nil);
                     }
                 }
                 else {
                     NSError* error2;
                     callback([NSJSONSerialization JSONObjectWithData:data
                                                              options:kNilOptions
                                                                error:&error2],nil);
                 }
             }
         });
     }];
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
