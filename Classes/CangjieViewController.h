//
//  CangjieViewController.h
//  Cangjie
//
//  Created by Wong Wan Leung on 31/08/2010.
/*
   Copyright 2010 Wan Leung Wong (wanleungwong at gmail dot com)
   http://www.wanleung.com

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

#import <UIKit/UIKit.h>

@interface CangjieViewController : UIViewController <UITextViewDelegate> {
	IBOutlet UITextView *uiTextView;
	IBOutlet UILabel *uiTextField;
	IBOutlet UISwitch *chineseInput;
	IBOutlet UIButton *copyButton;
	IBOutlet UIButton *clearButton;
	IBOutlet UIButton *inputTypeButton;
	IBOutlet UIButton *settingButton;
	IBOutlet UILabel *chineseInputLable;
	IBOutlet UIView *logoView;
	IBOutlet UIView *mainView;
	IBOutlet UIImageView *titleImage;
	IBOutlet UILabel *titleLable;
	IBOutlet UIView *inputPanel;
	//IBOutlet UIWordChoiceController *wordChoicePanel;
	
	IBOutlet UIButton *googleSearchButton;
	IBOutlet UIButton *emailButton;
	
	NSMutableDictionary *cangjie3Dict;
	NSMutableDictionary *cangjie5Dict;
	NSMutableDictionary *quickDict;
	NSDictionary *keydict;
	NSDictionary *orgCharDict;
	NSArray *inputIndexMap;
	
	NSString *inputString;
	NSMutableString *newInputString;
	unsigned int lastInputLength;
	NSMutableString *outputString;
	BOOL pending;
	BOOL finish;
	BOOL wordchoose;
	BOOL landscape;
	unsigned int inputIndex;
	NSArray *waitingList;
	NSMutableArray *buttons;
	NSMutableArray *quickParts;
	NSUserDefaults *mDefaultPrefs;
	
	int waitingListIndex;

	//UIBarButtonItem *barButtonItem;
	//UIToolbar *toolbar;

}

- (IBAction)clearTextView:(id)sender;

- (NSArray *)getChineseWord:(NSString *)code;

- (void)textViewDidChange:(UITextView *)textView;

- (void)createChooseButtons;
- (void)removeButtons;

- (NSString *)parseString:(NSString *)string;

- (IBAction)copyAll:(id)sender;

- (IBAction)switchType:(id)sender;

- (IBAction)nextWaitingList:(id)sender;

- (void)loadingDict;

- (IBAction)callSetting:(id)sender;

- (IBAction)callGoogle:(id)sender;

- (IBAction)callEmail:(id)sender;

- (void)loadDictFile:(NSMutableDictionary *)dict withMapFile:(NSString *)filePath;

- (void)keyboardWillShow:(NSNotification *)note;
- (void)keyboardDidHide:(NSNotification *)note;

@end

