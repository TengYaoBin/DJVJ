//
//  VideoShopPackageCell.m
//  DJVJ
//
//  Created by Bin on 2019/6/3.
//  Copyright © 2019 Bin. All rights reserved.
//

#import "VideoShopPackageCell.h"
#import "VideoCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "GlobalData.h"
@implementation VideoShopPackageCell

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
        self.btn_buy.titleLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        
    }else
    {
        //set night mode color
        self.contentView.backgroundColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        self.view_Package.backgroundColor = [UIColor colorWithRed:71/255.0 green:70/255.0 blue:70/255.0 alpha:1.0];
        self.lbl_PackageName.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        
        self.view_extend.backgroundColor = [UIColor colorWithRed:61/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
        self.collectionView_images.backgroundColor = [UIColor colorWithRed:61/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
        self.btn_buy.titleLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        
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
    [collectionView registerNib:[UINib nibWithNibName:@"VideoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"VideoCollectionViewCell"];
    VideoCollectionViewCell *itemCell = (VideoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCollectionViewCell" forIndexPath:indexPath];
    itemCell.layer.masksToBounds = NO;
    VideoItem *item = [self.videoPackage.videoList objectAtIndex:indexPath.row];
    [itemCell.img_view sd_setImageWithURL:[NSURL URLWithString:item.thumb_url]];
    [itemCell.img_highlighted setHidden:YES];
    return itemCell;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoPackage.videoList.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int item_width = self.collectionView_images.frame.size.width/2;
    int item_height = self.collectionView_images.frame.size.width / 3;
    return CGSizeMake(item_width, item_height);
}


@end
