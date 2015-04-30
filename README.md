# SimpleNetworking

Networking for Apple Watch, extensions, or other simple requests

Just one class to import

Examples:

#### 'GET' Stripe token
    [SimpleNetworking shared].headerFields = @{@"Authorization":@" Bearer yourtoken"};
    
    [SimpleNetworking postJsonToURL:@"https://api.stripe.com/v1/tokens" param:@{@"card[number]":@"4242424242424242",@"card[exp_month]":@"12",@"card[exp_year]":@"2016",@"card[cvc]":@"123"} returned:^(id responseObject, NSError *error) {
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

    NSDictionary *headerParams = @{@"token":@"something"};
    [SimpleNetworking shared].headerFields = headerParams;

Currently available:

Cached GET<br>
Cacheless GET<br>
Cached GET image<br>
Cacheless GET image<br>
Cacheless POST<br>
Cacheless POST image<br>
Cacheless PUT<br>
Cacheless DELETE<br>
