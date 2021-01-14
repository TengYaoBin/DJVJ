//
//  ImagePackageCell.m
//  DJVJ
//
//  Created by Bin on 2019/2/7.
//  Copyright © 2019 Bin. All rights reserved.
//

#import "ImagePackageCell.h"
#import "GlobalData.h"
#import "AppDelegate.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <CoreData/CoreData.h>

@implementation ImagePackageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.view_Package.layer.masksToBounds = YES;
    self.view_Package.layer.cornerRadius = 5;
    
    self.view_extend.layer.masksToBounds = YES;
    self.view_extend.layer.cornerRadius = 5;
    self.collectionView_images.layer.masksToBounds = NO;
    
    [self setTheme];
    // Initialization code
}
-(void)setTheme{
    GlobalData *global = [GlobalData sharedGlobalData];
    if (global.day_mode) {
        //set day mode color
        self.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.view_Package.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        self.lbl_PackageName.textColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        
        self.view_extend.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        self.collectionView_images.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        
    }else
    {
        //set night mode color
        self.contentView.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        self.view_Package.backgroundColor = [UIColor colorWithRed:71/255.0 green:70/255.0 blue:70/255.0 alpha:1.0];
        self.lbl_PackageName.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        
        self.view_extend.backgroundColor = [UIColor colorWithRed:61/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
        self.collectionView_images.backgroundColor = [UIColor colorWithRed:61/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
        
    }
}
- (void)reloadInputViews
{
    [self.collectionView_images reloadData];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [collectionView registerNib:[UINib nibWithNibName:@"ImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
    ImageCollectionViewCell *itemCell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    itemCell.layer.masksToBounds = NO;
    ImageItem *item = [self.imagePackage.imageList objectAtIndex:indexPath.row];
    
    itemCell.btn_item.tag = self.packageIndex * 1000 + (int)indexPath.row;
    [itemCell.btn_item addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DownloadImage"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id =  %@", item.image_id];
    [fetchRequest setPredicate:predicate];    
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSMutableArray *array_imageList = [[[self managedObjectContext] executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSString *downloadUrl = @"";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (array_imageList.count > 0) {
        NSManagedObject * imageNode = [array_imageList objectAtIndex:0];
        downloadUrl = [imageNode valueForKey:@"downloadUrl"];
    }
    if ([fileManager fileExistsAtPath:downloadUrl])
    {
        itemCell.img_view.image = [UIImage imageWithContentsOfFile:downloadUrl];
    }else
    {
        [itemCell.img_view sd_setImageWithURL:[NSURL URLWithString:item.image_url]];
    }
    
    GlobalData *global = [GlobalData sharedGlobalData];
    if ([global.selectedImageID isEqualToString:item.image_id]) {
        [itemCell.img_highlighted setHidden:NO];
        global.highlightedImageCell = itemCell;
        self.superController.selectedPackage = self.imagePackage;
        self.superController.selectedImage = item;        
        if ([fileManager fileExistsAtPath:downloadUrl])
        {
            [self.superController setSelectImage:[UIImage imageWithContentsOfFile:downloadUrl]];
        }else
        {
            [self.superController setSelectImage:itemCell.img_view.image];
        }
        
    }else
    {
        [itemCell.img_highlighted setHidden:YES];
    }
    return itemCell;
}

- (void)selectImage:(UIButton *)sender
{
    int index = (int)sender.tag % 1000;
    ImageItem *item = [self.imagePackage.imageList objectAtIndex:index];
    GlobalData *global = [GlobalData sharedGlobalData];
    
    global.selectedImageID = item.image_id;
    if (global.highlightedImageCell != nil) {
        [global.highlightedImageCell.img_highlighted setHidden:YES];
    }
    [self.collectionView_images reloadData];
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagePackage.imageList.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int item_width = self.collectionView_images.frame.size.width/2;
    int item_height = self.collectionView_images.frame.size.width / 3;
    return CGSizeMake(item_width, item_height);
}


- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    AppDelegate * delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    context = delegate.persistentContainer.viewContext;
    return context;
}
@end
