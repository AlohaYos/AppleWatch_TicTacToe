
#import "ViewController.h"
#import "Common.h"
#import "AppDelegate.h"

@interface ViewController () {
	
	AppDelegate*	appDelegate;
}

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// ログが更新された時のアプリ内通知を登録
	appDelegate = [UIApplication sharedApplication].delegate;
	[appDelegate registerLifeLogAddNotificationTo:self selector:@selector(dataChanged:)];
	
	// マーカー表示の初期化
	for(int i=0; i<9; i++) {
		[self setButton:i mark:mark_dot];	// マーカークリア
	}
	[_infoLabel setText:@"ゲームスタート"];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

// ボタンに指定のマークを表示する
- (void)setButton:(int)buttonNo mark:(int)markNo {
	
	NSString *mark;
	
	switch(markNo) {
		case mark_dot:
		default:
			mark = @"・";
			break;
		case mark_O:	// Apple Watch側のマーク
			mark = @"○";
			[_infoLabel setText:@"iPhoneの番です"];
			break;
		case mark_X:	// iPhone側のマーク
			mark = @"×";
			[_infoLabel setText:@"Apple Watchの番です"];
			break;
	}
	
	// ボタンにマークを設定する
	UIButton *btn = (UIButton *)[self.view viewWithTag:buttonNo+10];
	if(btn) {
		[btn setTitle:mark forState:UIControlStateNormal];
	}
}

#pragma mark - Data changed (Notification)

// Apple Watch側のボタンが押されたときにAppDelegateからアプリ内通知される
- (void)dataChanged:(NSNotification*)notification {
	
	// ボタン番号を取得
	NSNumber *buttonNumber = [notification.userInfo objectForKey:@"buttonNo"];
	
	[self setButton:buttonNumber.intValue mark:mark_O];	// Watchのエリアとしてマーク
}

#pragma mark - Button job

// ボタンが押された時の処理
- (IBAction)buttonPushed:(id)sender {
	
	UIButton *btn = sender;
	int buttonNo = (int)btn.tag-10;
	
	[self setButton:buttonNo mark:mark_X];	// iPhoneのエリアとしてマーク
	
	// WatchKitアプリにボタン番号を伝達する
	NSString *str = [NSString stringWithFormat:@"%@%d", GLOBAL_NOTIFY_NAME, buttonNo];	// （例）com.newtonjapan.SendToWatch.iPhoneMoved:2
	//notify_post([str UTF8String]);
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)str, NULL, NULL, YES);
}



@end
