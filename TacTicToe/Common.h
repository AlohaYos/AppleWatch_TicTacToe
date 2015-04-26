
#ifndef TicTacToe_Common_h
#define TicTacToe_Common_h

// マーク種別
enum {
	mark_dot,	// 未選択のマーク
	mark_O,		// Apple Watch側のマーク
	mark_X		// iPhone側のマーク
} areaMark;

// Darwin Notificatoin Center 識別子
#define GLOBAL_NOTIFY_NAME	@"com.myCompany.TicTacToe.iPhoneMoved:"

// NSNotificationCenter 識別子
#define APP_NOTIFY_NAME		@"watchMoved"

#endif
