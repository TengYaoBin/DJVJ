//
//  ImagePackageCell.h
//  DJVJ
//
//  Created by Bin on 2019/2/7.
//  Copyright © 2019 Bin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePackage.h"
#import "SelectImageViewController.h"
#import "ImageItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface ImagePackageCell : UITableViewCell<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong)  SelectImageViewController *superController;
@property (nonatomic, strong)  ImagePackage *imagePackage;
@property int packageIndex;
@property (weak, nonatomic) IBOutlet UIView *view_Package;
@property (weak, nonatomic) IBOutlet UILabel *lbl_PackageName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_counts;

@property (weak, nonatomic) IBOutlet UIButton *btn_extend;
@property (weak, nonatomic) IBOutlet UIImageView *img_extend;

@property (weak, nonatomic) IBOutlet UIView *view_extend;
@property (weak, nonatomic) IBOutlet UILabel *lbl_countsBottom;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView_images;
@end

NS_ASSUME_NONNULL_END
