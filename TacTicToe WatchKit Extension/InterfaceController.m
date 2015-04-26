
#import "InterfaceController.h"
#import "Common.h"

static id	myObj;	// C関数からselfへのアクセスポインタ

@interface InterfaceController() {
	
	NSArray* buttons;		// ボタンオブジェクト
}

@property (weak, nonatomic) IBOutlet WKInterfaceButton *button000;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *button001;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *button002;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *button003;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *button004;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *button005;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *button006;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *button007;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *button008;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *infoLabel;

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
	[super awakeWithContext:context];
	
	// Watch画面に配置したボタンオブジェクトの配列
	buttons = @[_button000, _button001, _button002,
				_button003, _button004, _button005,
				_button006, _button007, _button008,
				];
	
	// Cの関数でObjective-Cのメソッドを呼び出すための準備
	myObj = self;
	
	// iOS側からの通知を受け取る準備
	[self addObserver];
}

- (void)willActivate {
	
	[super willActivate];
	
	// マーカー表示の初期化
	for(int i=0; i<9; i++) {
		[self setButton:i mark:mark_dot];	// クリア
	}
	[_infoLabel setText:@"ゲームスタート"];
}

- (void)didDeactivate {
	[super didDeactivate];
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
	[buttons[buttonNo] setTitle:mark];
}

#pragma mark - Button job

// 各ボタンが押された時の処理
- (IBAction)button000Pushed { [self buttonPushed:0]; }
- (IBAction)button001Pushed { [self buttonPushed:1]; }
- (IBAction)button002Pushed { [self buttonPushed:2]; }
- (IBAction)button003Pushed { [self buttonPushed:3]; }
- (IBAction)button004Pushed { [self buttonPushed:4]; }
- (IBAction)button005Pushed { [self buttonPushed:5]; }
- (IBAction)button006Pushed { [self buttonPushed:6]; }
- (IBAction)button007Pushed { [self buttonPushed:7]; }
- (IBAction)button008Pushed { [self buttonPushed:8]; }

- (void)buttonPushed:(int)buttonNo {
	[self setButton:buttonNo mark:mark_O];	// Watchのエリアとしてマーク
	[self sendEventToOwnerApp:buttonNo];	// iOSアプリ側へボタン番号を通知
}

#pragma mark - iOSアプリへの情報送信

// iOSアプリにボタン番号を伝達する
- (void)sendEventToOwnerApp:(int)buttonNo {
	
	// 送信する情報
	NSDictionary *requst = @{@"buttonNo":[NSNumber numberWithInt:buttonNo]};
	
	// iOSアプリへ情報を送信し、応答を受信する
	[InterfaceController openParentApplication:requst reply:^(NSDictionary *replyInfo, NSError *error) {
		
		if (error) {
			NSLog(@"%@", error);	// エラー時の処理
		}
		else {
			// iOSアプリからの応答があればラベルに表示する
			NSString *response = [replyInfo objectForKey:@"response"];
			if(response.length > 0) {
				[_infoLabel setText:response];
			}
		}
	}];
}

#pragma mark - iOSアプリからの呼出しに応答

// iOS側からの通知（プロセス間通知）を受け取る関数を事前登録しておく
- (void)addObserver {
	
	for(int i=0; i<9; i++) {
		
		NSString *str = [NSString stringWithFormat:@"%@%d", GLOBAL_NOTIFY_NAME, i];
		
		// iOS側から通知を受けた時のコールバック関数を登録
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
										NULL,
										MyCallBack,			// コールバック関数
										(CFStringRef)str,	// ボタン番号 (0-8)を含む識別子 ... この識別子で通知された場合、MyCallBackを呼ぶ
										NULL,
										CFNotificationSuspensionBehaviorDeliverImmediately);
	}
}

// iOS側から通知を受けた時に呼び出される関数
// ここではnameパラメータを、そのままセレクタ名と解釈してメソッドを呼び出している
static void MyCallBack(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	
	NSString *button = (__bridge NSString *)name;		// （例）com.newtonjapan.SendToWatch.iPhoneMoved:2
	button = [button stringByReplacingOccurrencesOfString:GLOBAL_NOTIFY_NAME withString:@""];	// パラメータだけ抽出
	int buttonNo = [button intValue];
	
	// Objective-CのsetButton:mark:メソッドをコール
	SEL selector = @selector(setButton:mark:);
	((void (*)(id, SEL, int, int))[myObj methodForSelector:selector])(myObj, selector, buttonNo, mark_X);
}

@end



