//
//  LCLAddViewController.m
//  LCLFMDBModel
//
//  Created by 云淡风轻 on 2018/11/8.
//  Copyright © 2018 北京正图数创科技股份有限公司. All rights reserved.
//

#import "LCLEditViewController.h"

@interface LCLEditViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *hobbyLabel;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *hobbyTextField;

@end

@implementation LCLEditViewController

#pragma mark - ViewController Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"编辑联系人";
    self.view.backgroundColor = [UIColor whiteColor];
    
    /** 添加数据 */
    UIBarButtonItem * addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(downItemActin)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    if (self.person) {
        self.nameTextField.text = self.person.name;
        self.ageTextField.text = self.person.age;
        self.phoneTextField.text = self.person.phone;
        self.hobbyTextField.text = self.person.hobby;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.titleLabel.frame = CGRectMake(0, 64, LCLScreenWidth, 66);
    self.nameLabel.frame = CGRectMake(20, CGRectGetMaxY(self.titleLabel.frame) + 10, 66, 44);
    self.ageLabel.frame = CGRectMake(20, CGRectGetMaxY(self.nameLabel.frame) + 10, 66, 44);
    self.phoneLabel.frame = CGRectMake(20, CGRectGetMaxY(self.ageLabel.frame) + 10, 66, 44);
    self.hobbyLabel.frame = CGRectMake(20, CGRectGetMaxY(self.phoneLabel.frame) + 10, 66, 44);
    
    self.nameTextField.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) + 5, CGRectGetMaxY(self.titleLabel.frame) + 10, 250, 44);
    self.ageTextField.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) + 5, CGRectGetMaxY(self.nameLabel.frame) + 10, 250, 44);
    self.phoneTextField.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) + 5, CGRectGetMaxY(self.ageLabel.frame) + 10, 250, 44);
    self.hobbyTextField.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) + 5, CGRectGetMaxY(self.phoneLabel.frame) + 10, 250, 44);
}

#pragma mark - Actions
- (void)downItemActin {
    LCLPerson * person = [LCLPerson new];
    person.name = self.nameTextField.text;
    person.age = self.ageTextField.text;
    person.phone = self.phoneTextField.text;
    person.hobby = self.hobbyTextField.text;
    NSLog(@"%s - %@ - %@ - %@ - %@", __func__, person.name, person.age, person.phone, person.hobby);
    
    NSDate * date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    if (self.person) {
        person.userId = self.person.userId;
        // 数据库: 更新数据
        // 获取数据库
        [[LCLDataManager shareManager] createDatabaseWithName:@"user"];
        
        // 打开数据库
        [[LCLDataManager shareManager] openDatabase];
        
        // 获取表
        [[LCLDataManager shareManager] createTableWithName:@"t_contacts" class:[LCLPerson class]];
        
        // 更新数据 primaryKey: 表里的字段名, primaryValue: 字段对应的值
        [[LCLDataManager shareManager] updateWithTableName:@"t_contacts" model:person primaryKey:@"userId" primaryValue:person.userId];
        
        // 关闭数据库
        [[LCLDataManager shareManager] closeDatabase];
    } else {
        
        NSString * userId = [NSString stringWithFormat:@"%.f", timeInterval];
        person.userId = userId;
        
        // 数据库: 添加数据
        // 获取数据库
        [[LCLDataManager shareManager] createDatabaseWithName:@"user"];
        
        // 打开数据库
        [[LCLDataManager shareManager] openDatabase];
        
        // 获取表
        [[LCLDataManager shareManager] createTableWithName:@"t_contacts" class:[LCLPerson class]];
        
        // 向数据库写入数据
        [[LCLDataManager shareManager] insertWithTableName:@"t_contacts" model:person];
        
        // 关闭数据库
        [[LCLDataManager shareManager] closeDatabase];
    }
    
    // 更新列表
    self.refreshBlock(person);
    
    // 返回上级
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 退出键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
