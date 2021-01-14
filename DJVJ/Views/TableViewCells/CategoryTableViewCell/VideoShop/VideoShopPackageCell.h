//
//  VideoShopPackageCell.h
//  DJVJ
//
//  Created by Bin on 2019/6/3.
//  Copyright © 2019 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPackage.h"
#import "VideoItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoShopPackageCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong)  VideoPackage *videoPackage;
@property int packageIndex;
@property (weak, nonatomic) IBOutlet UIView *view_Package;
@property (weak, nonatomic) IBOutlet UILabel *lbl_PackageName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_price;

@property (weak, nonatomic) IBOutlet UIButton *btn_extend;
@property (weak, nonatomic) IBOutlet UIImageView *img_extend;
@property (weak, nonatomic) IBOutlet UIButton *btn_buy;

@property (weak, nonatomic) IBOutlet UIView *view_extend;
@property (weak, nonatomic) IBOutlet UILabel *lbl_countsBottom;
@property (weak, nonatomic) IBOutlet UILabel *lbl_videoSizeBottom;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView_images;@end

NS_ASSUME_NONNULL_END
