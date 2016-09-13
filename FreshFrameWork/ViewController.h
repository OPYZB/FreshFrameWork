//
//  ViewController.h
//  FreshFrameWork
//
//  Created by qq on 16/9/13.
//  Copyright © 2016年 yuncheda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPSessionManager.h"

@interface ViewController : UIViewController

#pragma mark - pull fresh
/** 会话管理者（用于网络请求） */
@property (nonatomic,weak) AFHTTPSessionManager *manager;
/** 话题数组（用于存放从服务器返回的数据） */
@property (nonatomic,strong) NSMutableArray *topics;

@property (nonatomic, strong) UIView *header;

@property (nonatomic, strong) UILabel *headerLabel;

@property (nonatomic, assign, getter=isWillLoadingNewData) BOOL willLoadingNewData;

@property (nonatomic, assign, getter=isLoadingNewData) BOOL loadingNewData;

/** 上拉刷新控件 */
@property (nonatomic, weak) UIView *footer;
/** 上拉刷新控件里面的文字 */
@property (nonatomic, weak) UILabel *footerLabel;
/** 是否正在加载更多数据 */
@property(nonatomic, assign, getter=isLoadingMoreData) BOOL loadingMoreData;

@end

