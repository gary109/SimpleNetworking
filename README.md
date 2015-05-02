# SimpleNetworking

Networking for Apple Watch, extensions, or other simple requests

Just one class to import

Examples:

#### `POST` for Stripe token

    NSString *url = @"https://api.stripe.com/v1/tokens";
    NSDictionary *param = @{@"card[number]":@"4242424242424242",@"card[exp_month]":@"12",@"card[exp_year]":@"2016",@"card[cvc]":@"123"}
    
    [SimpleNetworking shared].headerFields = @{@"Authorization":@" Bearer yourtoken"};

    [SimpleNetworking postJsonToURL:url param:param returned:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"error %@", error.localizedDescription);
                  }
        else {
            NSLog(@"%@", responseObject);
        }
    }];

#### `GET` Cacheless

    NSString *url = @"https://api.github.com/users/bibomain";
    [SimpleNetworking getJsonCachelessFromURL:url param:nil returned:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }
        else {
            NSLog(@"%@", responseObject);
        }
    }];

#### `GET` Cacheless `image`

    NSString *url = @"https://avatars.githubusercontent.com/u/7190067?v=3";
    [SimpleNetworking getImageCachelessFromURL:url param:nil returned:^(UIImage *responseImage, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }
        else {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
            imageView.image = responseImage;
            [self.view addSubview:imageView];
        }
    }];

#### `Set header`

    NSDictionary *headerParams = @{@"key":@"value"};
    [SimpleNetworking shared].headerFields = headerParams;

#### `Offline mode`
    
    Use only cache when internet is not available
    [SimpleNetworking shared].allowWorkingOffline = true;

#### `Custom cache size`
    
    [SimpleNetworking setCacheSizeMemoryCapacityInMB:16 diskCapacity:32];

#### `Customize security`

    - (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
    {
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    }

Cached GET<br>
Cacheless GET<br>
Cached GET image<br>
Cacheless GET image<br>
Cacheless POST<br>
Cacheless POST image<br>
Cacheless PUT<br>
Cacheless DELETE<br>
