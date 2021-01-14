//Gloabal Data Storage
/*------------- -------------*/
/*--------------------------------------------------------------------------*/
#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import "VideoCollectionViewCell.h"
#import "ImageCollectionViewCell.h"

@interface GlobalData : NSObject
+(GlobalData*)sharedGlobalData;
/*-------------color for theme-------------*/
    //night mode
    @property (nonatomic) UIColor *backgroundColor1;
    @property (nonatomic) UIColor *backgroundColor2;
    @property (nonatomic) UIColor *backgroundColor3;

//day mode
    @property (nonatomic) UIColor *backgroundColor4;
    @property (nonatomic) UIColor *backgroundColor5;
    @property (nonatomic) UIColor *backgroundColor6;

//general color
@property (nonatomic) UIColor *backgroundColor7;
@property (nonatomic) UIColor *backgroundColor8;
@property (nonatomic) UIColor *backgroundColor9;

//control color
@property (nonatomic) UIColor *backgroundColor00;
@property (nonatomic) UIColor *backgroundColor01;
@property (nonatomic) UIColor *backgroundColor10;
@property (nonatomic) UIColor *backgroundColor11;
@property (nonatomic) UIColor *backgroundColor20;
@property (nonatomic) UIColor *backgroundColor21;

/*--------------------------------------------------------------------------*/


//day_mode is false means that it is for night mode.
@property BOOL day_mode;

//video list
-(void)get_localFile;
-(void)get_videoList;
@property (nonatomic) NSString *selectedVideoID;
@property (nonatomic) VideoCollectionViewCell *highlightedVideoCell;
@property (nonatomic) NSMutableArray *availableVideoPackageArray;
@property (nonatomic) NSMutableArray *shopVideoPackageArray;

//image list
-(void)get_imageList;
@property (nonatomic) NSString *selectedImageID;
@property (nonatomic) ImageCollectionViewCell *highlightedImageCell;
@property (nonatomic) NSMutableArray *availableImagePackageArray;
@property (nonatomic) NSMutableArray *shopImagePackageArray;

//in app purchase key list [[NSDictionary alloc] initWithObjectsAndKeys:[obj_kit valueForKey:@"id"],@"id", [obj_kit valueForKey:@"kit_location"],@"kit_location", [obj_kit valueForKey:@"kit_id"],@"kit_id", [obj_kit valueForKey:@"box_state"],@"box_state", nil];
@property (nonatomic) NSSet *productIdentifiers;
@property (nonatomic) NSMutableArray *validProducts;
@property (nonatomic) NSMutableDictionary *iapKeyList;
@property int purchageVideoState;//1: available, 2: not exist
@property int purchageImageState;


@end
