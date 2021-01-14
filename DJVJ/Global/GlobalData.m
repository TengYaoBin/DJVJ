
#import "GlobalData.h"
#import "VideoPackage.h"
#import "VideoItem.h"
#import "ImagePackage.h"
#import "ImageItem.h"
#import "AppDelegate.h"

#import <CoreData/CoreData.h>


@implementation GlobalData

+(GlobalData*)sharedGlobalData{
    static GlobalData * sharedInstance = nil;
    
    if(sharedInstance == nil){
        sharedInstance = [[GlobalData alloc] init];
        sharedInstance.backgroundColor1 = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0];
        sharedInstance.backgroundColor2 = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        sharedInstance.backgroundColor3 = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        
        sharedInstance.backgroundColor4 = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
        sharedInstance.backgroundColor5 = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        sharedInstance.backgroundColor6 = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        
        sharedInstance.backgroundColor7 = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
        sharedInstance.backgroundColor8 = [UIColor colorWithRed:138.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1.0];
        sharedInstance.backgroundColor9 = [UIColor colorWithRed:254.0/255.0 green:254.0/255.0 blue:254.0/255.0 alpha:1.0];
        
        sharedInstance.backgroundColor00 = [UIColor colorWithRed:133/255.0 green:93/255.0 blue:251/255.0 alpha:1.0];
        sharedInstance.backgroundColor01 = [UIColor colorWithRed:224/255.0 green:208/255.0 blue:255/255.0 alpha:1.0];
        sharedInstance.backgroundColor10 = [UIColor colorWithRed:43/255.0 green:211/255.0 blue:212/255.0 alpha:1.0];
        sharedInstance.backgroundColor11 = [UIColor colorWithRed:168/255.0 green:242/255.0 blue:243/255.0 alpha:1.0];
        sharedInstance.backgroundColor20 = [UIColor colorWithRed:0/255.0 green:149/255.0 blue:255/255.0 alpha:1.0];
        sharedInstance.backgroundColor21 = [UIColor colorWithRed:158/255.0 green:225/255.0 blue:255/255.0 alpha:1.0];
        
        sharedInstance.day_mode = false;
        
        sharedInstance.availableVideoPackageArray = [[NSMutableArray alloc] init];
        sharedInstance.shopVideoPackageArray = [[NSMutableArray alloc] init];
        sharedInstance.selectedVideoID = @"00";
        
        sharedInstance.availableImagePackageArray = [[NSMutableArray alloc] init];
        sharedInstance.shopImagePackageArray = [[NSMutableArray alloc] init];
        sharedInstance.selectedImageID = @"00";
        sharedInstance.iapKeyList = [[NSMutableDictionary alloc] init];
        sharedInstance.productIdentifiers = [NSSet setWithObjects:@"DJVJIAP0001I",@"DJVJIAP0002I",@"DJVJIAP0003I",@"DJVJIAP0004I",@"DJVJIAP0005I",@"DJVJIAP0006I",nil];
        sharedInstance.purchageImageState = 0;
        sharedInstance.purchageVideoState = 0;
    }
    return sharedInstance;
}

//get videolist

-(void)get_localFile
{
    //get local video
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DownloadVideoPackage"];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    NSMutableArray *array_packageList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if (array_packageList.count > 0) {
        NSMutableArray *availableVideoPackageArray = [[NSMutableArray alloc] init];
        
        for (NSManagedObject *packageItem in array_packageList) {
            VideoPackage *videoPackage = [[VideoPackage alloc] init];
            
            fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DownloadVideo"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"package_id =  %@", [packageItem valueForKey:@"id"]];
            [fetchRequest setPredicate:predicate];
            [fetchRequest setReturnsObjectsAsFaults:NO];
            NSMutableArray *array_videoList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
            
            NSMutableArray *videoArray = [[NSMutableArray alloc] init];
            for (NSManagedObject *videoItem in array_videoList) {
                VideoItem *item = [[VideoItem alloc] init];
                NSString *video_id = [videoItem valueForKey:@"id"];
                NSString *video_url = [videoItem valueForKey:@"video_url"];
                NSString *packageID = [packageItem valueForKey:@"id"];
                item.video_id = video_id;
                item.package_id = packageID;
                item.video_url = video_url;
                [videoArray addObject:item];
            }
            videoPackage.package_id = [packageItem valueForKey:@"id"];
            videoPackage.name = [packageItem valueForKey:@"name"];
            videoPackage.width = [packageItem valueForKey:@"width"];
            videoPackage.height = [packageItem valueForKey:@"height"];            
            videoPackage.videoList = videoArray;
            [availableVideoPackageArray addObject:videoPackage];
        }
        self.availableVideoPackageArray = availableVideoPackageArray;
    }
    
    //get local images
    fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DownloadImagePackage"];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    array_packageList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if (array_packageList.count > 0) {
        
        NSMutableArray *availableImagePackageArray = [[NSMutableArray alloc] init];
        
        for (NSManagedObject *packageItem in array_packageList) {
            ImagePackage *imagePackage = [[ImagePackage alloc] init];
            fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DownloadImage"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"package_id =  %@", [packageItem valueForKey:@"id"]];
            [fetchRequest setPredicate:predicate];
            [fetchRequest setReturnsObjectsAsFaults:NO];
            NSMutableArray *array_imageList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
            
            NSMutableArray *imageArray = [[NSMutableArray alloc] init];
            for (NSManagedObject *imageItem in array_imageList) {
                ImageItem *item = [[ImageItem alloc] init];
                NSString *image_id = [imageItem valueForKey:@"id"];
                NSString *image_url = [imageItem valueForKey:@"image_url"];
                NSString *packageID = [packageItem valueForKey:@"id"];                
                item.image_id = image_id;
                item.package_id = packageID;
                item.image_url = image_url;
                [imageArray addObject:item];
            }
            imagePackage.package_id = [packageItem valueForKey:@"id"];
            imagePackage.name = [packageItem valueForKey:@"name"];
            imagePackage.imageList = imageArray;
            [availableImagePackageArray addObject:imagePackage];
        }
        self.availableImagePackageArray = availableImagePackageArray;
    }
}

-(void)get_videoList
{
    NSString *urlString = @"http://51.77.200.144/djvj_server/rest_api/get_videos.php";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *postDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if (error) {
            
        }else
        {
            NSDictionary* jsonDict=[[NSDictionary alloc] init];
            jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:&error];
            NSString *videoRootUrl = @"http://51.77.200.144/djvj_server/videos/";
            NSString *thumbRootUrl = @"http://51.77.200.144/djvj_server/videos_thumbnail/";
            NSMutableArray *availableVideoPackageArray = [[NSMutableArray alloc] init];
            NSMutableArray *shopVideoPackageArray = [[NSMutableArray alloc] init];
            
            NSMutableArray *free_array = [jsonDict objectForKey:@"free"];
            for (int i = 0; i<free_array.count; i++) {
                VideoPackage *videoPackage = [[VideoPackage alloc] init];
                NSDictionary *package_obj = [free_array objectAtIndex:i];
                
                NSString *package_id = [package_obj objectForKey:@"id"];
                NSString *name = [package_obj objectForKey:@"name"];
                NSString *price = [package_obj objectForKey:@"price"];
                NSString *width = [package_obj objectForKey:@"width"];
                NSString *height = [package_obj objectForKey:@"height"];
                
                NSMutableArray *videoArray = [[NSMutableArray alloc] init];
                NSMutableArray *videos = [package_obj objectForKey:@"videos"];
                for (int j = 0; j<videos.count; j++) {
                    NSDictionary *video_obj = [videos objectAtIndex:j];
                    VideoItem *item = [[VideoItem alloc] init];
                    NSString *video_id = [video_obj objectForKey:@"id"];
                    NSString *video_url = [NSString stringWithFormat:@"%@%@",videoRootUrl,[video_obj objectForKey:@"video_url"]];
                    NSString *packageID = [video_obj objectForKey:@"package_id"];
                    NSString *thumb_url = [NSString stringWithFormat:@"%@%@",thumbRootUrl,[video_obj objectForKey:@"thumb_url"]];
                    item.video_id = video_id;
                    item.video_url = video_url;
                    item.package_id = packageID;
                    item.thumb_url = thumb_url;
                    [videoArray addObject:item];
                }
                videoPackage.package_id = package_id;
                videoPackage.name = name;
                videoPackage.price = price;
                videoPackage.width = width;
                videoPackage.height = height;
                videoPackage.videoList = videoArray;
                [availableVideoPackageArray addObject:videoPackage];
            }
            
            NSMutableArray *shop_array = [jsonDict objectForKey:@"shop"];
            if (shop_array.count > 0) {
                self.purchageVideoState = 1;
            }else
            {
                self.purchageVideoState = 2;
            }
            for (int i = 0; i<shop_array.count; i++) {
                VideoPackage *videoPackage = [[VideoPackage alloc] init];
                NSDictionary *package_obj = [shop_array objectAtIndex:i];
                
                NSString *package_id = [package_obj objectForKey:@"id"];
                NSString *name = [package_obj objectForKey:@"name"];
                NSString *price = [package_obj objectForKey:@"price"];
                NSString *productID = [package_obj objectForKey:@"ProductIDIOS"];
                NSString *width = [package_obj objectForKey:@"width"];
                NSString *height = [package_obj objectForKey:@"height"];
                
                NSMutableArray *videoArray = [[NSMutableArray alloc] init];
                NSMutableArray *videos = [package_obj objectForKey:@"videos"];
                
                for (int j = 0; j<videos.count; j++) {
                    NSDictionary *video_obj = [videos objectAtIndex:j];
                    VideoItem *item = [[VideoItem alloc] init];
                    NSString *video_id = [video_obj objectForKey:@"id"];
                    NSString *video_url = [NSString stringWithFormat:@"%@%@",videoRootUrl, [video_obj objectForKey:@"video_url"]];
                    NSString *packageID = [video_obj objectForKey:@"package_id"];
                    NSString *thumb_url = [NSString stringWithFormat:@"%@%@",thumbRootUrl, [video_obj objectForKey:@"thumb_url"]];
                    item.video_id = video_id;
                    item.video_url = video_url;
                    item.package_id = packageID;
                    item.thumb_url = thumb_url;
                    [videoArray addObject:item];
                }
                videoPackage.package_id = package_id;
                videoPackage.name = name;
                videoPackage.price = price;
                videoPackage.width = width;
                videoPackage.height = height;
                videoPackage.productID = productID;
                videoPackage.videoList = videoArray;
                NSMutableSet *mSet = [[NSMutableSet alloc] initWithSet:self.productIdentifiers];
                [mSet addObject:productID];
                self.productIdentifiers = [mSet copy];
                //[self.productIdentifiers setByAddingObject:productID];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PurchageVideo"];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"package_id =  %@", package_id];
                    [fetchRequest setPredicate:predicate];
                    [fetchRequest setReturnsObjectsAsFaults:NO];
                    
                    NSMutableArray *array_frameList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
                    if (array_frameList.count > 0) {
                        [availableVideoPackageArray addObject:videoPackage];
                    }else
                    {
                        [shopVideoPackageArray addObject:videoPackage];
                    }
                });
            }            
            self.shopVideoPackageArray = shopVideoPackageArray;
            self.availableVideoPackageArray = availableVideoPackageArray;
        }        
    }];
    [postDataTask resume];
}

//get imagelist
-(void)get_imageList
{
    NSString *urlString = @"http://51.77.200.144/djvj_server/rest_api/get_images.php";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *postDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if (error) {
            
        }else
        {
            NSDictionary* jsonDict=[[NSDictionary alloc] init];
            jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:kNilOptions
                                                         error:&error];
            NSString *imageRootUrl = @"http://51.77.200.144/djvj_server/images/";
            NSMutableArray *availableImagePackageArray = [[NSMutableArray alloc] init];
            NSMutableArray *shopImagePackageArray = [[NSMutableArray alloc] init];
            
            NSMutableArray *free_array = [jsonDict objectForKey:@"free"];
            for (int i = 0; i<free_array.count; i++) {
                ImagePackage *imagePackage = [[ImagePackage alloc] init];
                NSDictionary *package_obj = [free_array objectAtIndex:i];
                
                NSString *package_id = [package_obj objectForKey:@"id"];
                NSString *name = [package_obj objectForKey:@"name"];
                NSString *price = [package_obj objectForKey:@"price"];
                
                NSMutableArray *imageArray = [[NSMutableArray alloc] init];
                NSMutableArray *images = [package_obj objectForKey:@"images"];
                for (int j = 0; j<images.count; j++) {
                    NSDictionary *image_obj = [images objectAtIndex:j];
                    ImageItem *item = [[ImageItem alloc] init];
                    NSString *image_id = [image_obj objectForKey:@"id"];
                    NSString *image_url = [NSString stringWithFormat:@"%@%@",imageRootUrl,[image_obj objectForKey:@"image_url"]];
                    NSString *packageID = [image_obj objectForKey:@"package_id"];
                    item.image_id = image_id;
                    item.image_url = image_url;
                    item.package_id = packageID;
                    [imageArray addObject:item];
                }
                imagePackage.package_id = package_id;
                imagePackage.name = name;
                imagePackage.price = price;
                imagePackage.imageList = imageArray;
                [availableImagePackageArray addObject:imagePackage];
            }
            
            NSMutableArray *shop_array = [jsonDict objectForKey:@"shop"];
            if (shop_array.count > 0) {
                self.purchageImageState = 1;
            }else
            {
                self.purchageImageState = 2;
            }
            for (int i = 0; i<shop_array.count; i++) {
                ImagePackage *imagePackage = [[ImagePackage alloc] init];
                NSDictionary *package_obj = [shop_array objectAtIndex:i];
                
                NSString *package_id = [package_obj objectForKey:@"id"];
                NSString *name = [package_obj objectForKey:@"name"];
                NSString *price = [package_obj objectForKey:@"price"];
                NSString *productID = [package_obj objectForKey:@"ProductIDIOS"];
                
                NSMutableArray *imageArray = [[NSMutableArray alloc] init];
                NSMutableArray *images = [package_obj objectForKey:@"images"];
                
                for (int j = 0; j<images.count; j++) {
                    NSDictionary *image_obj = [images objectAtIndex:j];
                    ImageItem *item = [[ImageItem alloc] init];
                    NSString *image_id = [image_obj objectForKey:@"id"];
                    NSString *image_url = [NSString stringWithFormat:@"%@%@",imageRootUrl,[image_obj objectForKey:@"image_url"]];
                    NSString *packageID = [image_obj objectForKey:@"package_id"];
                    item.image_id = image_id;
                    item.image_url = image_url;
                    item.package_id = packageID;
                    [imageArray addObject:item];
                }
                imagePackage.package_id = package_id;
                imagePackage.name = name;
                imagePackage.price = price;
                imagePackage.productID = productID;
                imagePackage.imageList = imageArray;
                
                NSMutableSet *mSet = [[NSMutableSet alloc] initWithSet:self.productIdentifiers];
                [mSet addObject:productID];
                self.productIdentifiers = [mSet copy];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PurchageImage"];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"package_id =  %@", package_id];
                    [fetchRequest setPredicate:predicate];
                    [fetchRequest setReturnsObjectsAsFaults:NO];
                    
                    NSMutableArray *array_frameList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
                    if (array_frameList.count > 0) {
                        [availableImagePackageArray addObject:imagePackage];
                    }else
                    {
                        [shopImagePackageArray addObject:imagePackage];
                    }
                });
            }
            self.shopImagePackageArray = shopImagePackageArray;
            self.availableImagePackageArray = availableImagePackageArray;
        }
        
    }];
    [postDataTask resume];
}


- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    AppDelegate * delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    context = delegate.persistentContainer.viewContext;
    return context;
}

@end
