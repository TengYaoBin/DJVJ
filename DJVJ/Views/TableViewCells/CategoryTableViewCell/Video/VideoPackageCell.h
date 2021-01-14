//
//  VideoPackageCell.h
//  CollectionViewInTableView
//
//  Created by Bin on 2019/1/8.
//  Copyright © 2019 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoPackage.h"
#import "SelectVideoViewController.h"
#import "VideoItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface VideoPackageCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong)  SelectVideoViewController *superController;
@property (nonatomic, strong)  VideoPackage *videoPackage;
@property int packageIndex;
@property (weak, nonatomic) IBOutlet UIView *view_Package;
@property (weak, nonatomic) IBOutlet UILabel *lbl_PackageName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_counts;
@property (weak, nonatomic) IBOutlet UILabel *lbl_videoSize;

@property (weak, nonatomic) IBOutlet UIButton *btn_extend;
@property (weak, nonatomic) IBOutlet UIImageView *img_extend;

@property (weak, nonatomic) IBOutlet UIView *view_extend;
@property (weak, nonatomic) IBOutlet UILabel *lbl_countsBottom;
@property (weak, nonatomic) IBOutlet UILabel *lbl_videoSizeBottom;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView_images;
@end

NS_ASSUME_NONNULL_END
