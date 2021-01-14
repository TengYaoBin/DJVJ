//
//  LeftMenuViewController.m
//  LeftSideMenuControllerDemo
//
//  Created by tomfriwel on 02/03/2017.
//  Copyright © 2017 tomfriwel. All rights reserved.

#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>
//
#import "SelectVideoViewController.h"

#import "LeftMenuViewController.h"
#import "OutputTableViewCell.h"
#import "InputTableViewCell.h"
#import "VideoShopViewController.h"
#import "ImageShopViewController.h"


@interface LeftMenuViewController ()<UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate,SKPaymentTransactionObserver>
{
    BOOL day_mode;
    GlobalData *global;
    NSMutableArray *output_size_list;
    NSMutableArray *input_audio_list;
    NSMutableArray *output_reSize_list;
    NSMutableArray *output_rate_list;
    NSString *current_outputSize;
    NSString *current_audioInput;
    NSString *current_outputreSize;
    NSString *current_outputRate;
}

@end

@implementation LeftMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    global = [GlobalData sharedGlobalData];
    day_mode = global.day_mode;
    [self.view_sub_setting setHidden:YES];
    [self.view_sub_support setHidden:YES];
    [self.view_sub_upgrades setHidden:YES];
    [self.tbl_outputSize setHidden:YES];
    [self.view_select setHidden:YES];
    [self.tbl_inputAudio setHidden:YES];
    [self.tbl_outputResize setHidden:YES];
    [self.tbl_outputRate setHidden:YES];
    
    [self setTheme];
    //hide output subview, support subview, upgrade subview
    [self.height_constraint_sub_setting setConstant:0.0];
    [self.height_constraint_sub_support setConstant:0.0];
    [self.height_constraint_sub_upgrades setConstant:0.0];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"iap_extend"] isEqualToString:@"1"]) {
        //purchased
        output_size_list = [[NSMutableArray alloc] initWithObjects:
                            @"256 x 144",
                            @"384 x 216",
                            @"512 x 288",
                            @"640 x 360",
                            @"852 x 480",
                            @"1280 x 720",
                            @"1920 x 1080",
                            @"320 x 240",
                            @"640 x 480",
                            @"800 x 600",
                            @"1024 x 768",
                            @"1152 x 864",
                            @"1280 x 960",
                            @"1400 x 1050",
                            nil];
        
    }else
    {
        //not purchased
        output_size_list = [[NSMutableArray alloc] initWithObjects:
                            @"256 x 144",
                            @"640 x 360",
                            @"1280 x 720",
                            @"320 x 240",
                            @"640 x 480",
                            @"1024 x 768",
                            nil];
    }
    

    
    input_audio_list = [[NSMutableArray alloc] initWithObjects:@"mic", @"itunes", nil];
    output_reSize_list = [[NSMutableArray alloc] initWithObjects:@"Crop", @"Stretch", nil];
    output_rate_list = [[NSMutableArray alloc] initWithObjects:
                        @"12",
                        @"24",
                        @"25",
                        @"29",
                        @"30",
                        @"48",
                        @"50",
                        @"60",
                        nil];
    current_outputSize = [NSString stringWithFormat:@"%@ x %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"width"],[[NSUserDefaults standardUserDefaults] objectForKey:@"height"]];
    current_audioInput = [[NSUserDefaults standardUserDefaults] objectForKey:@"audio_input"];
    current_outputreSize = [[NSUserDefaults standardUserDefaults] objectForKey:@"output_resize"];
    current_outputRate = [[NSUserDefaults standardUserDefaults] objectForKey:@"output_rate"];
    
    self.lbl_output_value.text = [NSString stringWithFormat:@"%@ px",current_outputSize];
    self.lbl_audioInput_value.text = current_audioInput;
    self.lbl_outputResize_value.text = current_outputreSize;
    self.lbl_outputRate_value.text = [NSString stringWithFormat:@"%@ FPS",current_outputRate];
    
    //set tableview style
    self.tbl_outputSize.layer.cornerRadius = 6.0;
    self.tbl_outputSize.clipsToBounds = YES;
    self.tbl_outputSize.layer.borderColor = [UIColor colorWithRed:0.0/255.0 green:149.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor;
    self.tbl_outputSize.layer.borderWidth = 2;
    self.tbl_outputSize.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tbl_inputAudio.layer.cornerRadius = 6.0;
    self.tbl_inputAudio.clipsToBounds = YES;
    self.tbl_inputAudio.layer.borderColor = [UIColor colorWithRed:0.0/255.0 green:149.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor;
    self.tbl_inputAudio.layer.borderWidth = 2;
    self.tbl_inputAudio.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tbl_outputResize.layer.cornerRadius = 6.0;
    self.tbl_outputResize.clipsToBounds = YES;
    self.tbl_outputResize.layer.borderColor = [UIColor colorWithRed:0.0/255.0 green:149.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor;
    self.tbl_outputResize.layer.borderWidth = 2;
    self.tbl_outputResize.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tbl_outputRate.layer.cornerRadius = 6.0;
    self.tbl_outputRate.clipsToBounds = YES;
    self.tbl_outputRate.layer.borderColor = [UIColor colorWithRed:0.0/255.0 green:149.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor;
    self.tbl_outputRate.layer.borderWidth = 2;
    self.tbl_outputRate.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tbl_outputSize reloadData];
    [self.tbl_inputAudio reloadData];
    [self.tbl_outputResize reloadData];
    [self.tbl_outputRate reloadData];
}

- (IBAction)btn_setting_clicked:(id)sender {
    if (self.height_constraint_sub_setting.constant > 1.0) {
        //hide sub setting
        [self.view_sub_setting setHidden:YES];
        [self.height_constraint_sub_setting setConstant:
         0.0];
    }else
    {
        //show sub setting
        [self.view_sub_setting setHidden:NO];
        [self.height_constraint_sub_setting setConstant:240.0];
    }
    
}

- (IBAction)action_select_output:(id)sender {
    // show output type table view
    [self.view_select setHidden:NO];
    [self.tbl_outputSize setHidden:NO];
    [self.tbl_inputAudio setHidden:YES];
    [self.tbl_outputResize setHidden:YES];
    [self.tbl_outputRate setHidden:YES];
    [self.tbl_outputSize reloadData];
    self.img_outputSize.image = [UIImage imageNamed:@"icon_arrowdown_0095FF_active.png"];
}

- (IBAction)action_select_audio_input_type:(id)sender {
    // show audio input type table view
    [self.view_select setHidden:NO];
    [self.tbl_outputSize setHidden:YES];
    [self.tbl_inputAudio setHidden:NO];
    [self.tbl_outputResize setHidden:YES];
    [self.tbl_outputRate setHidden:YES];
    [self.tbl_inputAudio reloadData];
    self.img_audioInput.image = [UIImage imageNamed:@"icon_arrowdown_0095FF_active.png"];
}

- (IBAction)action_select_outputResize:(id)sender {
    // show output resize table view
    [self.view_select setHidden:NO];
    [self.tbl_outputSize setHidden:YES];
    [self.tbl_inputAudio setHidden:YES];
    [self.tbl_outputResize setHidden:NO];
    [self.tbl_outputRate setHidden:YES];
    [self.tbl_outputResize reloadData];
    self.img_outputResize.image = [UIImage imageNamed:@"icon_arrowdown_0095FF_active.png"];
}

- (IBAction)action_select_outputRate:(id)sender {
    // show output rate table view
    [self.view_select setHidden:NO];
    [self.tbl_outputSize setHidden:YES];
    [self.tbl_inputAudio setHidden:YES];
    [self.tbl_outputResize setHidden:YES];
    [self.tbl_outputRate setHidden:NO];
    [self.tbl_outputRate reloadData];
    self.img_outputRate.image = [UIImage imageNamed:@"icon_arrowdown_0095FF_active.png"];
}

- (IBAction)action_support:(id)sender {
    if (self.height_constraint_sub_support.constant > 1.0) {
        //hide sub setting
        [self.view_sub_support setHidden:YES];
        [self.height_constraint_sub_support setConstant:
         0.0];
    }else
    {
        //show sub setting
        [self.view_sub_support setHidden:NO];
        [self.height_constraint_sub_support setConstant:180.0];
    }
}

//send mail

- (IBAction)action_email:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        
        NSString *emailTitle = @"DJVJ";
        NSString *messageBody = @"";
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:@"support@djvj.app"];
        
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        [self presentViewController:mc animated:YES completion:NULL];
    }else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Restore Mail?" message:@"To follow this link you need th     uue app Mail, which is no longer installed on your device. You can download it again in the App Store." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Display in App Store" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //go to app mail app on app store
            NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/mail/id1108187098?mt=8"];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)action_fac:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://djvj.app/faq"]] options:@{} completionHandler:nil];
}

- (IBAction)action_credit:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://djvj.app/credits"]] options:@{} completionHandler:nil];
}

- (IBAction)action_go_videoShop:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    VideoShopViewController *videoShopViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"VideoShopViewController"];
    videoShopViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.mainViewController presentViewController:videoShopViewController animated:NO completion:nil];
}

- (IBAction)action_go_imageShop:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    ImageShopViewController *imageShopViewController= [self.storyboard instantiateViewControllerWithIdentifier:@"ImageShopViewController"];
    imageShopViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.mainViewController presentViewController:imageShopViewController animated:NO completion:nil];
}

- (IBAction)action_upgrade:(id)sender {
    if (self.height_constraint_sub_upgrades.constant > 1.0) {
        //hide sub upgrade
        [self.view_sub_upgrades setHidden:YES];
        [self.height_constraint_sub_upgrades setConstant:
         0.0];
    }else
    {
        //show sub upgrade
        [self.view_sub_upgrades setHidden:NO];
        [self.height_constraint_sub_upgrades setConstant:180.0];
    }
}



//IAP support part
- (IBAction)action_extend_output:(id)sender {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"iap_extend"] isEqualToString:@"1"]) {
        // already purchased
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"You already purchased this upgrade." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    for (SKProduct *validProduct in global.validProducts) {
        if ([validProduct.productIdentifier isEqualToString:@"DJVJIAP0003I"]) {
            if ([SKPaymentQueue canMakePayments]) {
//                [global.iapKeyList valueForKey:videoPackage.productID];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:validProduct.localizedTitle message:[NSString stringWithFormat:@"PRICE : %@ \n %@",[global.iapKeyList valueForKey:validProduct.productIdentifier], validProduct.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Buy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    SKPayment *payment = [SKPayment paymentWithProduct:validProduct];
                    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
                    [[SKPaymentQueue defaultQueue] addPayment:payment];
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {                    
                }]];
                [self presentViewController:alertController animated:YES completion:nil];                
            }else
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Not Available" message:@"Purchases are disabled in your device." preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            
            return;
        }
    }
}

- (IBAction)action_no_watermark:(id)sender {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"iap_watermark"] isEqualToString:@"1"]) {
        // already purchased
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"You already purchased this upgrade." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    for (SKProduct *validProduct in global.validProducts) {
        if ([validProduct.productIdentifier isEqualToString:@"DJVJIAP0005I"]) {
            if ([SKPaymentQueue canMakePayments]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:validProduct.localizedTitle message:[NSString stringWithFormat:@"PRICE : %@ \n %@",[global.iapKeyList valueForKey:validProduct.productIdentifier], validProduct.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Buy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    SKPayment *payment = [SKPayment paymentWithProduct:validProduct];
                    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
                    [[SKPaymentQueue defaultQueue] addPayment:payment];
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }else
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Not Available" message:@"Purchases are disabled in your device." preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            
            return;
        }
    }
}

- (IBAction)action_no_watermark_output:(id)sender {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"iap_watermark_output"] isEqualToString:@"1"]) {
        // already purchased
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"You already purchased this upgrade." preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    for (SKProduct *validProduct in global.validProducts) {
        if ([validProduct.productIdentifier isEqualToString:@"DJVJIAP0006I"]) {
            if ([SKPaymentQueue canMakePayments]) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:validProduct.localizedTitle message:[NSString stringWithFormat:@"PRICE : %@ \n %@",[global.iapKeyList valueForKey:validProduct.productIdentifier], validProduct.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Buy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    SKPayment *payment = [SKPayment paymentWithProduct:validProduct];
                    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
                    [[SKPaymentQueue defaultQueue] addPayment:payment];
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }else
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Not Available" message:@"Purchases are disabled in your device." preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            
            return;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Purchased");
                if ([transaction.payment.productIdentifier isEqualToString:@"DJVJIAP0003I"]) {
                    //purchased extend output successfully
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"iap_extend"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else if ([transaction.payment.productIdentifier isEqualToString:@"DJVJIAP0005I"]) {
                    //purchased no watermark successfully
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"iap_watermark"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else if ([transaction.payment.productIdentifier isEqualToString:@"DJVJIAP0006I"]) {
                    //purchased no watermark successfully
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"iap_watermark_output"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Restored");
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Purchase failed");
                break;
                
            default:
                break;
        }
    }
}




- (IBAction)action_change_dayMode:(id)sender {
    if (day_mode) {
        //set night mode
        global.day_mode = false;
    }else {
        //set day mode
        global.day_mode = true;
    }
    [self.mainViewController setTheme];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setTheme{
    if (global.day_mode) {
        //setting day mode
        self.img_dayMode.image = [UIImage imageNamed:@"icon_nightmode_0095FF_default.png"];
        self.lbl_dayMode.text = @"NIGHT MODE";
        
        //set day theme background color
        [self.view_top setBackgroundColor:global.backgroundColor5];
        [self.view_body setBackgroundColor:global.backgroundColor6];
        [self.view_bottom setBackgroundColor:global.backgroundColor5];
        
        [self.img_underline1 setBackgroundColor:global.backgroundColor5];
        [self.img_underline2 setBackgroundColor:global.backgroundColor5];
        [self.img_underline3 setBackgroundColor:global.backgroundColor5];
        [self.img_underline4 setBackgroundColor:global.backgroundColor5];
        [self.img_underline5 setBackgroundColor:global.backgroundColor5];
        [self.img_underline6 setBackgroundColor:global.backgroundColor5];
        [self.img_underline7 setBackgroundColor:global.backgroundColor5];
        [self.img_underline8 setBackgroundColor:global.backgroundColor5];
        [self.img_underline9 setBackgroundColor:global.backgroundColor5];
        [self.img_underline10 setBackgroundColor:global.backgroundColor5];
        [self.img_underline11 setBackgroundColor:global.backgroundColor5];
        [self.img_underline12 setBackgroundColor:global.backgroundColor5];
        [self.img_underline13 setBackgroundColor:global.backgroundColor5];
        [self.img_underline14 setBackgroundColor:global.backgroundColor5];
        [self.img_underline15 setBackgroundColor:global.backgroundColor5];
        
        [self.lbl_output_title setTextColor:global.backgroundColor1];
        [self.lbl_audioInput_title setTextColor:global.backgroundColor1];
        [self.lbl_outputResize_title setTextColor:global.backgroundColor1];
        [self.lbl_outputRate_title setTextColor:global.backgroundColor1];
        self.tbl_outputSize.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.tbl_inputAudio.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.tbl_outputResize.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        self.tbl_outputRate.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        
    }else {
        //setting night mode
        self.img_dayMode.image = [UIImage imageNamed:@"icon_daymode_0095FF_default.png"];
        self.lbl_dayMode.text = @"DAY MODE";
        
        //set night theme color
        [self.view_top setBackgroundColor:global.backgroundColor2];
        [self.view_body setBackgroundColor:global.backgroundColor2];
        [self.view_bottom setBackgroundColor:global.backgroundColor2];
        
        [self.img_underline1 setBackgroundColor:global.backgroundColor3];
        [self.img_underline2 setBackgroundColor:global.backgroundColor3];
        [self.img_underline3 setBackgroundColor:global.backgroundColor3];
        [self.img_underline4 setBackgroundColor:global.backgroundColor3];
        [self.img_underline5 setBackgroundColor:global.backgroundColor3];
        [self.img_underline6 setBackgroundColor:global.backgroundColor3];
        [self.img_underline7 setBackgroundColor:global.backgroundColor3];
        [self.img_underline8 setBackgroundColor:global.backgroundColor3];
        [self.img_underline9 setBackgroundColor:global.backgroundColor3];
        [self.img_underline10 setBackgroundColor:global.backgroundColor3];
        [self.img_underline11 setBackgroundColor:global.backgroundColor3];
        [self.img_underline12 setBackgroundColor:global.backgroundColor3];
        [self.img_underline13 setBackgroundColor:global.backgroundColor3];
        [self.img_underline14 setBackgroundColor:global.backgroundColor3];
        [self.img_underline15 setBackgroundColor:global.backgroundColor3];
        
        [self.lbl_output_title setTextColor:global.backgroundColor9];
        [self.lbl_audioInput_title setTextColor:global.backgroundColor9];
        [self.lbl_outputResize_title setTextColor:global.backgroundColor9];
        [self.lbl_outputRate_title setTextColor:global.backgroundColor9];
        self.tbl_outputSize.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.tbl_inputAudio.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.tbl_outputResize.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.tbl_outputRate.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];        
    }
}





//tableview delegate and data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 100) {
        //output video size
        return output_size_list.count;
    }else if (tableView.tag == 200)
    {
        //input audio source type
        return input_audio_list.count;
    }else if (tableView.tag == 300)
    {
        //output resize type
        return output_reSize_list.count;
    }else
    {
        //output frame rate
        return output_rate_list.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 100) {
        //output video size
        OutputTableViewCell *cell = (OutputTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OutputCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (global.day_mode) {
            cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
            cell.view_bottom.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        }else
        {
            cell.contentView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
            cell.view_bottom.backgroundColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        }
        
        NSString *videoSize = [output_size_list objectAtIndex:indexPath.row];
        if (indexPath.row < output_size_list.count/2) {
            //16:9 mode
            cell.lbl_type.text = [NSString stringWithFormat:@"%@ px (16:9)",videoSize];
        }else
        {
            //4:3 mode
            cell.lbl_type.text = [NSString stringWithFormat:@"%@ px (4:3)",videoSize];
        }
        
        if ([current_outputSize isEqualToString:videoSize]) {
            cell.lbl_type.textColor = [UIColor colorWithRed:0.0/255.0 green:149.0/255.0 blue:255.0/255.0 alpha:1.0];
            cell.lbl_type.layer.shadowColor = [cell.lbl_type.textColor CGColor];
            cell.lbl_type.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            cell.lbl_type.layer.shadowRadius = 4.0;
            cell.lbl_type.layer.shadowOpacity = 0.5;
            cell.lbl_type.layer.masksToBounds = NO;
        }else
        {
            cell.lbl_type.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
            cell.lbl_type.layer.shadowRadius = 0.0;
        }
        return cell;
    }else if (tableView.tag == 200)
    {
        //input audio source type
        InputTableViewCell *cell = (InputTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"InputCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (global.day_mode) {
            cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
            cell.view_bottom.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        }else
        {
            cell.contentView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
            cell.view_bottom.backgroundColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        }
        NSString *audioInput = [input_audio_list objectAtIndex:indexPath.row];
        cell.lbl_type.text = audioInput;
        if ([current_audioInput isEqualToString:audioInput]) {
            cell.lbl_type.textColor = [UIColor colorWithRed:0.0/255.0 green:149.0/255.0 blue:255.0/255.0 alpha:1.0];
            cell.lbl_type.layer.shadowColor = [cell.lbl_type.textColor CGColor];
            cell.lbl_type.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            cell.lbl_type.layer.shadowRadius = 4.0;
            cell.lbl_type.layer.shadowOpacity = 0.5;
            cell.lbl_type.layer.masksToBounds = NO;
        }else
        {
            cell.lbl_type.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
            cell.lbl_type.layer.shadowRadius = 0.0;
        }
        return cell;
    }else if (tableView.tag == 300)
    {
        //output resizing type
        OutputTableViewCell *cell = (OutputTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OutputCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (global.day_mode) {
            cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
            cell.view_bottom.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        }else
        {
            cell.contentView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
            cell.view_bottom.backgroundColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        }
        
        NSString *resizetype = [output_reSize_list objectAtIndex:indexPath.row];
        cell.lbl_type.text = resizetype;
        if ([current_outputreSize isEqualToString:resizetype]) {
            cell.lbl_type.textColor = [UIColor colorWithRed:0.0/255.0 green:149.0/255.0 blue:255.0/255.0 alpha:1.0];
            cell.lbl_type.layer.shadowColor = [cell.lbl_type.textColor CGColor];
            cell.lbl_type.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            cell.lbl_type.layer.shadowRadius = 4.0;
            cell.lbl_type.layer.shadowOpacity = 0.5;
            cell.lbl_type.layer.masksToBounds = NO;
        }else
        {
            cell.lbl_type.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
            cell.lbl_type.layer.shadowRadius = 0.0;
        }
        return cell;
    }else
    {
        //output framerate
        OutputTableViewCell *cell = (OutputTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OutputCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (global.day_mode) {
            cell.contentView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
            cell.view_bottom.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
        }else
        {
            cell.contentView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
            cell.view_bottom.backgroundColor = [UIColor colorWithRed:72.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1.0];
        }
        
        NSString *frameRate = [output_rate_list objectAtIndex:indexPath.row];
        cell.lbl_type.text = [NSString stringWithFormat:@"%@ FPS",frameRate];
        
        if ([current_outputRate isEqualToString:frameRate]) {
            cell.lbl_type.textColor = [UIColor colorWithRed:0.0/255.0 green:149.0/255.0 blue:255.0/255.0 alpha:1.0];
            cell.lbl_type.layer.shadowColor = [cell.lbl_type.textColor CGColor];
            cell.lbl_type.layer.shadowOffset = CGSizeMake(0.0, 0.0);
            cell.lbl_type.layer.shadowRadius = 4.0;
            cell.lbl_type.layer.shadowOpacity = 0.5;
            cell.lbl_type.layer.masksToBounds = NO;
        }else
        {
            cell.lbl_type.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
            cell.lbl_type.layer.shadowRadius = 0.0;
        }
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view_select setHidden:YES];
    if (tableView.tag == 100) {
        //output video size
        self.img_outputSize.image = [UIImage imageNamed:@"icon_arrowdown_0095FF_default.png"];
        current_outputSize = [output_size_list  objectAtIndex:indexPath.row];
        self.lbl_output_value.text = [NSString stringWithFormat:@"%@ px",current_outputSize];
        //set output width and height
        NSArray *size_array = [current_outputSize componentsSeparatedByString:@" x "];
        [[NSUserDefaults standardUserDefaults] setObject:[size_array objectAtIndex:0] forKey:@"width"];
        [[NSUserDefaults standardUserDefaults] setObject:[size_array objectAtIndex:1] forKey:@"height"];
        self.mainViewController.outputWidth = [[size_array objectAtIndex:0] intValue];
        self.mainViewController.outputHeight = [[size_array objectAtIndex:1] intValue];
        [self.mainViewController resume_timer];
    }else if (tableView.tag == 200)
    {
        //input audio source type
        self.img_audioInput.image = [UIImage imageNamed:@"icon_arrowdown_0095FF_default.png"];
        current_audioInput = [input_audio_list  objectAtIndex:indexPath.row];
        self.lbl_audioInput_value.text = current_audioInput;
        
        //set audio input source
        [[NSUserDefaults standardUserDefaults] setObject:current_audioInput forKey:@"audio_input"];
        [self.mainViewController setInput_mode];
    }else if (tableView.tag == 300)
    {
        //output resize type
        self.img_outputResize.image = [UIImage imageNamed:@"icon_arrowdown_0095FF_default.png"];
        current_outputreSize = [output_reSize_list  objectAtIndex:indexPath.row];
        self.lbl_outputResize_value.text = current_outputreSize;
        
        //set audio input source
        [[NSUserDefaults standardUserDefaults] setObject:current_outputreSize forKey:@"output_resize"];
//        [self.mainViewController setInput_mode];
    }else
    {
        //output frame rate
        self.img_outputRate.image = [UIImage imageNamed:@"icon_arrowdown_0095FF_default.png"];
        current_outputRate = [output_rate_list  objectAtIndex:indexPath.row];
        self.lbl_outputRate_value.text = [NSString stringWithFormat:@"%@ FPS",current_outputRate];
        
        //set audio input source
        [[NSUserDefaults standardUserDefaults] setObject:current_outputRate forKey:@"output_rate"];
        [self.mainViewController resume_timer];
    }
}

/*-------------------------------- ---------------------------------------------------------*/




@end
