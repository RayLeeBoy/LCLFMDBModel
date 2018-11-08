//
//  LCLSearchViewController.m
//  LCLFMDBModel
//
//  Created by 云淡风轻 on 2018/11/8.
//  Copyright © 2018 北京正图数创科技股份有限公司. All rights reserved.
//

#import "LCLSearchViewController.h"
#import "LCLAddViewController.h"

@interface LCLSearchViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end

@implementation LCLSearchViewController

#pragma mark - ViewController Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"联系人列表";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.containerView.frame = CGRectMake(0, 64, LCLScreenWidth, 66);
    self.searchTextField.frame = CGRectMake(15, 11, LCLScreenWidth - 15 - 66 - 15 - 15, 44);
    self.searchButton.frame = CGRectMake(LCLScreenWidth - 15 - 66, 11, 66, 44);
    self.tableView.frame = CGRectMake(0, 64 + 66, LCLScreenWidth, LCLScreenHeight - 64 - 66);
}

#pragma mark - Actions
- (IBAction)searchButtonAction {
    NSLog(@"%s", __func__);
    [self loadNewData];
}

- (void)loadNewData {
    // 数据库: 添加数据
    [[LCLDataManager shareManager] createDatabaseWithName:@"user"];
    [[LCLDataManager shareManager] openDatabase];
    [[LCLDataManager shareManager] createTableWithName:@"t_contacts" class:[LCLPerson class]];
    NSMutableArray * mArr = [[LCLDataManager shareManager] queryWithTableName:@"t_contacts" key:@"phone" value:self.searchTextField.text];
    self.dataSource = mArr;
    [self.tableView reloadData];
    [[LCLDataManager shareManager] closeDatabase];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * identifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.dataSource.count > 0) {
        LCLPerson * person = self.dataSource[indexPath.row];
        NSString * firstStr = [NSString stringWithFormat:@"姓名: %@   年龄: %@", person.name, person.age];
        NSString * secondStr = [NSString stringWithFormat:@"电话: %@  爱好: %@", person.phone, person.hobby];
        cell.textLabel.text = firstStr;
        cell.detailTextLabel.text = secondStr;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __func__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定删除本吗?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
        [[LCLDataManager shareManager] openDatabase];
        
        LCLPerson * person = self.dataSource[indexPath.row];
        [[LCLDataManager shareManager] removeWithTableName:@"t_contacts" key:@"phone" value:person.phone];
        
        [[LCLDataManager shareManager] closeDatabase];
        
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:sureAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __func__);
    LCLPerson * person = self.dataSource[indexPath.row];
    UIStoryboard * main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LCLAddViewController * vc = [main instantiateViewControllerWithIdentifier:@"LCLAddViewController"];
    vc.refreshBlock = ^(LCLPerson *person) {
        [self loadNewData];
    };
    vc.person = person;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - LazyLoad
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        
        _tableView = tableView;
    }
    return _tableView;
}

@end
