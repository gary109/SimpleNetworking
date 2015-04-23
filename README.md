# SimpleNetworking

Feel free to just copy it and make it [whatever]Networking

A simple wrapper for making network calls, just one class to import

Examples:

Cacheless GET

    NSString *url = @"https://api.github.com/users/bibomain";
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

Set header

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
