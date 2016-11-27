//
//  ViewController.h
//  BLETester
//
//  Created by Mapple on 2016/11/13.
//  Copyright © 2016年 Maple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)searchAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)initAction:(id)sender;
- (IBAction)scanAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@end

