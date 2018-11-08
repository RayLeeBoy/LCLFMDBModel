//
//  LCLAddViewController.h
//  LCLFMDBModel
//
//  Created by 云淡风轻 on 2018/11/8.
//  Copyright © 2018 北京正图数创科技股份有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^RefreshBlock)(LCLPerson *);
@interface LCLAddViewController : UIViewController


/**
 在本页面添加联系人成功后, 让联系人列表刷新
 */
@property (nonatomic, copy) RefreshBlock refreshBlock;

@end
