# SimpleNetworking
A simple wrapper for making network calls, just one class to import

Examples:

Cacheless GET

    [SimpleNetworking getJsonCachelessFromURL:url param:nil returned:^(id responseObject, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }
        else {
            NSLog(@"%@", responseObject);
        }
    }];
    
Cacheless GET image

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

Currently available:

Cached GET
Cacheless GET
Cached GET image
Cacheless GET image
Cacheless POST
Cacheless POST image
Cacheless PUT
Cacheless DELETE
