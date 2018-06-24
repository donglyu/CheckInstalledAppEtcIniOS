//
//  ViewController.m
//  testPrivateAPI
//
//  Created by donglyu on 2018/6/19.
//  Copyright © 2018年 donglyu. All rights reserved.
//

#import "ViewController.h"
#include <objc/runtime.h>
#import <dlfcn.h>
//#import <LSApplicationWorkspace.h>

@interface ViewController ()

@property (nonatomic, strong) NSObject* workspace;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    _workspace = workspace;
}


#pragma mark - Private.

/** 获取所有系统已安装的应用。*/
- (IBAction)GetAllInstalledApps:(id)sender {
    
    NSArray *allApplications = [self.workspace performSelector:@selector(allApplications)];//这样就能获取到手机中安装的所有App
//    NSLog(@"设备上安装的所有app:%@",allApplications);
    for ( id object in allApplications) {
        // 其他更多支持方法请看：https://github.com/nst/iOS-Runtime-Headers/blob/master/Frameworks/MobileCoreServices.framework/LSApplicationProxy.h
        id resultObj = [object performSelector:NSSelectorFromString(@"applicationIdentifier")]; // shortVersionString、applicationIdentifier
        NSLog(@"%@", resultObj);
    }
}

/** 检测是否已安装某个ID的应用 */
- (IBAction)JudgeHadInstalledApp:(id)sender {
    NSString *bundleId = @"com.apple.webapp"; //
    
    BOOL isInstall = [self.workspace performSelector:@selector(applicationIsInstalled:) withObject:bundleId];
    if (isInstall) {
        NSLog(@"已安装%@，尝试打开！", bundleId);
        //通过bundle id打开一个APP。注意，如果这个App正在下载，返回值也为YES。
        [self.workspace performSelector:@selector(openApplicationWithBundleID:) withObject:bundleId];
    }else{
        NSLog(@"您还没安装%@", bundleId);
    }
}

/** 通过定时器不断调用来获取系统中所有正在下载的内容及进度。*/
- (IBAction)TimerUpdateToGetDownloadProgress:(id)sender {
    

    void *lib = dlopen("/System/Library/Frameworks/MobileCoreServices.framework/MobileCoreServices", RTLD_LAZY);
    
    if (lib){
        Class LSApplicationWorkspace = NSClassFromString(@"LSApplicationWorkspace");
        id AAURLConfiguration1 = [LSApplicationWorkspace performSelector:@selector(defaultWorkspace)];
    
        
        if (AAURLConfiguration1){
            id arrApp = [AAURLConfiguration1 performSelector:@selector(allApplications)];
            
            for (int i=0; i<[arrApp count]; i++) {
                
                id LSApplicationProxy = [arrApp objectAtIndex:i];
                NSString* bundleId =[LSApplicationProxy performSelector:@selector(applicationIdentifier)];
                NSString* name = [LSApplicationProxy localizedName];
                
                NSProgress *progress = (NSProgress *)[LSApplicationProxy performSelector:@selector(installProgress)];
                
                NSLog(@"current progress:%lf bundleId:%@", [NSProgress currentProgress], bundleId);
                // 正在安装的模型数据
//                InstallingModel *model = [self getInstallModel:bundleId];
                
                //如果是正在下载状态
                if (progress){
                    
                    //已经检测到的
//                    if (model) {
                    
//                        model.progress = [progress localizedDescription];
//                        model.status  =  [NSString stringWithFormat:@"%@",[[progress userInfo] valueForKey:@"installState"]];
                        //第一次检测到的
//                    }else{
//                        InstallingModel *model = [[InstallingModel alloc] init];
//                        model.appName = name;
//                        model.bundleID = bundleId;
//                        model.progress = [progress localizedDescription];
//                        model.status  = [NSString stringWithFormat:@"%@",[[progress userInfo] valueForKey:@"installState"]];
//
//                        [_installedAry addObject:model];
//                    }
                    
                }
            }
        }
        if (lib) dlclose(lib);
    }
    
    
}

#pragma mark - Helper.


#pragma mark - Other.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
