//
//  ViewController.m
//  FreshFrameWork
//
//  Created by qq on 16/9/13.
//  Copyright © 2016年 yuncheda. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Frame.h"

#define NavHeight 64

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger _currentPage;
    NSInteger _pagesize;
    BOOL _isFirstPage;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"test Fresh";
    [self.view addSubview:self.tableView];
    
    // 初始化数据
    _currentPage = 1;
    _pagesize = 10;
    _isFirstPage = YES;
    
    // 加载数据
    [self loadNewTopicData];
    // 设置刷新控件
    [self setUpRefresh];
}


#pragma mark - 代理方法
/**
 * 当scrollView在滚动,就会调用这个代理方法
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 处理下拉刷新
    [self dealLoadNewData];
    // 处理上拉加载更多
    [self dealLoadMoreData];
}

/**
 * 当用户手松开(停止拖拽),就会调用这个代理方法
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.isLoadingNewData || self.willLoadingNewData == NO) return;
    
    self.headerLabel.text = @"正在帮你加载";
    self.loadingNewData = YES;
    // 发送请求
    [self loadNewTopicData];
    // 增加顶部的内边距
    [UIView animateWithDuration:1.0 animations:^{
        UIEdgeInsets inset = self.tableView.contentInset; // contentInset默认是0,在content的周围增加额外的scroll范围
        inset.top += self.header.height; // 新的contentInset变成了0 + 64的高度
        self.tableView.contentInset = inset;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.5 options:(UIViewAnimationOptionAllowAnimatedContent) animations:^{
            self.headerLabel.text = @"加载完成";
            
            UIEdgeInsets inset = self.tableView.contentInset; // 在加载完成的时候移除顶部的内边距
            inset.top -= self.header.height; // 新的contentInset变成了64 - 64
            self.tableView.contentInset = inset;
        } completion:^(BOOL finished) { // 刷新完成之后要做的操作
            // 修改文字
            self.headerLabel.text = @"下拉可以加载数据...";
            // 将正在刷新,即将要加载新数据这两个属性置为no,使其显示静态的文字提示信息
            self.loadingNewData = NO;
            self.willLoadingNewData = NO;
            // 刷新完成之后将headr 的label 的透明度置为0,为完全透明
            self.header.alpha = 0.0;
        }];
    }];
}

/**
 * 处理下拉刷新
 */
- (void)dealLoadNewData
{
    // 如果是正在刷新数据，则直接返回
    if (self.loadingNewData) return;
    
    // 设置固定偏移量offsetY
    CGFloat offsetY =  - (NavHeight  + self.header.height);
    // 设置透明度
    CGFloat alpha = (self.tableView.contentOffset.y + NavHeight  + self.header.height)/self.header.height;
    if (alpha>1) {
        alpha = 1;
    }
    self.header.alpha = 1- alpha;
    //如果Y轴偏移量与offsetY比较大小，进行一些操作
    if (self.tableView.contentOffset.y <= offsetY) {
        self.headerLabel.text = @"松开立即刷新";
        self.willLoadingNewData = YES;
    } else {
        self.headerLabel.text = @"下拉可以刷新";
        self.willLoadingNewData = NO;
    }
}

/**
 * 处理上拉加载更多
 */
- (void)dealLoadMoreData
{
    // 显示上拉刷新控件
    self.footer.hidden = NO;
    
    // 如果没有数据 或者 正在上拉刷新, 直接返回
    if (self.topics.count == 0 || self.loadingMoreData) return;
    
    CGFloat offsetY = self.tableView.contentSize.height + self.tableView.contentInset.bottom - self.tableView.height;
    if (self.tableView.contentOffset.y >= offsetY) {
        self.loadingMoreData = YES;
        
        // 更改文字
        self.footerLabel.text = @"正在加载更多的数据...";
        
        // 加载更多的帖子数据
        [UIView animateWithDuration:0.25 delay:0.25 options:(UIViewAnimationOptionAllowAnimatedContent) animations:^{
            [self loadMoreTopicData];
        } completion:^(BOOL finished) {
            self.loadingMoreData = NO;
            // 更改文字
            self.footerLabel.text = @"上拉加载更多的数据...";
        }];
    }
}

/**
 * 刷新数据网络请求
 */
- (void)loadNewTopicData {
    NSString *str = @"http://api.yunluwang.com/router?appKey=00001&messageFormat=json&method=user.initHelpCenter&v=1.0&sign=A024D52E453B1804FD2B18AD9BD6A940C4272A21";
    
    // 1.创建会话管理者
    self.manager = [AFHTTPSessionManager manager];
    
    // 2.拼接请求参数
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@(_currentPage) forKey:@"currentPage"];
    [parameters setValue:@(_pagesize) forKey:@"pageSize"];
    
    [self.manager GET:str parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject == nil) return ;
        // 给话题数组赋值数据
        NSLog(@"rws - %@", responseObject);
        
        _currentPage = 1;
        [self.topics removeAllObjects];
        
        for (NSDictionary * dic in responseObject[@"data"][@"rmList"]) {
            [self.topics addObject:dic[@"yhcMessageTitle"]];
        }
        
        // 刷新数据
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

# pragma mark - 加载更多的数据（旧数据）###################
/**
 * 加载更多数据
 */
- (void)loadMoreTopicData{
    NSString *str = @"http://api.yunluwang.com/router?appKey=00001&messageFormat=json&method=user.initHelpCenter&v=1.0&sign=A024D52E453B1804FD2B18AD9BD6A940C4272A21";
    _currentPage++;
    
    // 1.创建会话管理者
    self.manager = [AFHTTPSessionManager manager];
    
    // 2.拼接请求参数
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@(_currentPage) forKey:@"currentPage"];
    [parameters setValue:@(_pagesize) forKey:@"pageSize"];
    
    [self.manager GET:str parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (responseObject == nil) return ;
        
        for (NSDictionary * dic in responseObject[@"data"][@"rmList"]) {
            [self.topics addObject:dic[@"yhcMessageTitle"]];
        }

        // 刷新数据
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

- (void)setUpRefresh {
#pragma mark -下拉刷新控件 ###################
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [UIColor yellowColor];
    header.height = 60;
    header.width = self.tableView.width;
    header.y = - header.height;
    [self.tableView addSubview:header];
    self.header = header;
    // 头部提醒文字headerLabel
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.text = @"下拉可以刷新";
    headerLabel.width = self.tableView.width;
    headerLabel.height = header.height;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    self.header.alpha = 0.0;
    [header addSubview:headerLabel];
    self.headerLabel = headerLabel;
#pragma mark - 上拉加载控件 ##################
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = [UIColor orangeColor];
    footer.height = 35;
    footer.hidden = YES;
    self.tableView.tableFooterView = footer;
    self.footer = footer;
    // 尾部提醒文字footerLabel
    UILabel *footerLabel = [[UILabel alloc] init];
    footerLabel.text = @"上拉可以加载更多";
    footerLabel.width = self.tableView.width;
    footerLabel.height = footer.height;
    footerLabel.textAlignment = NSTextAlignmentCenter;
    [footer addSubview:footerLabel];
    self.footerLabel = footerLabel;
}

#pragma mark - UITableViewDelegate Method, UITableViewDataSource Method
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuse = @"test";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuse];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuse];
    }
    
    cell.textLabel.text = _topics[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _topics.count;
}

#pragma mark - lazy loading
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)topics {
    if (!_topics) {
        _topics = [NSMutableArray array];
    }
    return _topics;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
