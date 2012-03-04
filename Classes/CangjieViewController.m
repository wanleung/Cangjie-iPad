//
//  CangjieViewController.m
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

#import "CangjieViewController.h"

@implementation CangjieViewController


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	landscape = NO;
	keydict = [[NSDictionary alloc] init];
	cangjie3Dict = [[NSMutableDictionary alloc] init];
	cangjie5Dict = [[NSMutableDictionary alloc] init];
	quickDict = [[NSMutableDictionary alloc] init];
	newInputString = [[NSMutableString alloc] init];
	outputString = [[NSMutableString alloc] init];
	[outputString appendString:@""];
	[uiTextView setDelegate:self];
	waitingList = [[NSArray alloc] init]; 
	uiTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	uiTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
	pending = NO;
	finish = YES;
	wordchoose = NO;
	//selectIndex = 0;
	waitingListIndex = 0;

	//wordChoicePanel = [[UIWordChoiceController alloc] init];
	
	mDefaultPrefs = [[NSUserDefaults standardUserDefaults] retain];
	
	buttons = [[NSMutableArray alloc] init];
	quickParts = [[NSMutableArray alloc] init];
	
	uiTextView.text = @"";
	uiTextField.text = @"";
	lastInputLength = [uiTextField.text length];
    logoView.hidden = NO;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	
    [self.view bringSubviewToFront:logoView];
	
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(loadingDict) userInfo:nil repeats:NO];
	
	
	////
	// NOT FUNCTION
	[googleSearchButton setHidden:YES];
	[emailButton setHidden:YES];
}

- (void)loadDictFile:(NSMutableDictionary *)dict withMapFile:(NSString *)filePath {
	NSString *myText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
	
	if (myText) {  
		NSArray *array = [myText componentsSeparatedByString:@"\n"];
		for (NSString *string in array) {
			//NSLog(@"%@", [string substringWithRange:NSMakeRange(0,2)]);
			if ([string isEqualToString:@""]) {
				continue;
			}
			if ([string length]>2 && [[string substringWithRange:NSMakeRange(0,2)] isEqualToString:@"##"]) {
				
				continue;
			}
			NSArray *tmp = [string componentsSeparatedByString:@"\t"];
			//NSLog(@"%@", tmp);
			if ([dict objectForKey:[tmp objectAtIndex:0]]) {
				NSMutableDictionary *tmpdict = [dict objectForKey:[tmp objectAtIndex:0]];
				[tmpdict setObject:[tmp objectAtIndex:1] forKey:[tmp objectAtIndex:2]];
			} else {
				NSMutableDictionary *tmpdict = [NSMutableDictionary dictionaryWithObject:[tmp objectAtIndex:1] forKey:[tmp objectAtIndex:2]];
				[dict setObject:tmpdict forKey:[tmp objectAtIndex:0]];
			}
			
			//[dict setObject:tmp forKey:[tmp objectAtIndex:0]];
		}
		//NSLog(@"%@", dict);
		
	}
	
}

- (void)loadingDict {
	[logoView setNeedsDisplay];
	[self.view setNeedsDisplay];
	
	NSString *charMapPath = [[NSBundle mainBundle] pathForResource:@"charmap" ofType:@"plist"];
	if (charMapPath) {
		orgCharDict = [[NSDictionary alloc] initWithContentsOfFile:charMapPath];
		//NSLog(@"%@", orgCharDict);
	}
	//NSLog(@"%@", orgCharDict);
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CangJie3" ofType:@"txt"];  
	if (filePath) { 
		[self loadDictFile:cangjie3Dict withMapFile:filePath];
    }
	
	filePath = [[NSBundle mainBundle] pathForResource:@"CangJie5" ofType:@"txt"];  
	if (filePath) {
		[self loadDictFile:cangjie5Dict withMapFile:filePath];
	}
	
	filePath = [[NSBundle mainBundle] pathForResource:@"Quick" ofType:@"txt"];  
	if (filePath) {
		[self loadDictFile:quickDict withMapFile:filePath];
	}
	
	inputIndexMap = [NSArray arrayWithObjects:@"changie3", @"changie5", @"quick", nil];
	
	if ([mDefaultPrefs objectForKey:@"LastInputType"]) {
		if ([[mDefaultPrefs objectForKey:@"LastInputType"] isEqualToString:@"changie3"]) {
			[keydict release];
			keydict = [cangjie3Dict retain];
			[inputTypeButton setTitle:@"\u5009\u4e09" forState:UIControlStateNormal];
		} else if ([[mDefaultPrefs objectForKey:@"LastInputType"] isEqualToString:@"changie5"]){
			[keydict release];
			keydict = [cangjie5Dict retain];
			[inputTypeButton setTitle:@"\u5009\u4e94" forState:UIControlStateNormal];
		} else if ([[mDefaultPrefs objectForKey:@"LastInputType"] isEqualToString:@"quick"]) {
			[keydict release];
			keydict = [quickDict retain];
			[inputTypeButton setTitle:@"\u901f\u6210" forState:UIControlStateNormal];
		}
	} else {
		[mDefaultPrefs setObject:@"changie3" forKey:@"LastInputType"];
		[keydict release];
		keydict = [cangjie3Dict retain];
		[inputTypeButton setTitle:@"\u5009\u4e09" forState:UIControlStateNormal];
	}
	inputIndex = [inputIndexMap indexOfObject:[mDefaultPrefs objectForKey:@"LastInputType"]];
	logoView.hidden = YES;
	[logoView setNeedsDisplay];
	[self.view bringSubviewToFront:mainView];
	[self.view setNeedsDisplay];
	[uiTextView becomeFirstResponder];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		if (!landscape) {
			CGRect org = chineseInputLable.frame;
			[chineseInputLable setFrame:CGRectMake(org.origin.x+256, org.origin.y, org.size.width, org.size.height)];
			org = copyButton.frame;
			[copyButton setFrame:CGRectMake(org.origin.x+256, org.origin.y, org.size.width, org.size.height)];
			
			org = clearButton.frame;
			[clearButton setFrame:CGRectMake(org.origin.x+256, org.origin.y, org.size.width, org.size.height)];
			
			org = chineseInput.frame;
			[chineseInput setFrame:CGRectMake(org.origin.x+256, org.origin.y, org.size.width, org.size.height)];
			
			org = logoView.frame;
			[logoView setFrame:CGRectMake(org.origin.x, org.origin.y, 1024.0, 748.0)];
			[titleImage setFrame:CGRectMake(256, 63, 512, 512)];
			[titleLable setFrame:CGRectMake(160, 580, 728, 91)];
			
			org = settingButton.frame;
			[settingButton setFrame:CGRectMake(org.origin.x+256, org.origin.y, org.size.width, org.size.height)];
			
			org = inputPanel.frame;
			[inputPanel setFrame:CGRectMake(0, 296, 1024, 472)];
			
			[self.view setNeedsDisplay];	
			landscape = YES;
		}
	} else {
		if (landscape) {
			CGRect org = chineseInputLable.frame;
			[chineseInputLable setFrame:CGRectMake(org.origin.x-256, org.origin.y, org.size.width, org.size.height)];
			org = copyButton.frame;
			[copyButton setFrame:CGRectMake(org.origin.x-256, org.origin.y, org.size.width, org.size.height)];
			
			org = clearButton.frame;
			[clearButton setFrame:CGRectMake(org.origin.x-256, org.origin.y, org.size.width, org.size.height)];
			
			org = chineseInput.frame;
			[chineseInput setFrame:CGRectMake(org.origin.x-256, org.origin.y, org.size.width, org.size.height)];
			
			org = logoView.frame;
			[logoView setFrame:CGRectMake(org.origin.x, org.origin.y, 768.0, 1004.0)];
			[titleImage setFrame:CGRectMake(128, 175, 512, 512)];
			[titleLable setFrame:CGRectMake(20, 695, 728, 91)];
			
			org = settingButton.frame;
			[settingButton setFrame:CGRectMake(org.origin.x-256, org.origin.y, org.size.width, org.size.height)];
			
			org = inputPanel.frame;
			[inputPanel setFrame:CGRectMake(0, 640, 768, 364)];
			
			[self.view setNeedsDisplay];
			landscape = NO;
		}
	
	}

    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


//==============================================================================

- (IBAction)clearTextView:(id)sender {
	[outputString release];
	outputString = [[NSMutableString alloc] init];
	uiTextView.text = outputString;
}

- (NSArray *)getChineseWord:(NSString *)code {
	NSLog(@"HSHS");
	NSMutableArray *tmptmp = [[NSMutableArray alloc] init];
	//NSLog(@"HSHS, %@", code);
	NSMutableDictionary *resultdict = [keydict objectForKey:code];
	NSLog(@"HSHS");
	if (resultdict) {
		if ([resultdict count] == 1) {
			NSLog(@"%@", resultdict);
			[tmptmp addObject:[[resultdict allValues] objectAtIndex:0] ];
			return [tmptmp autorelease];
		} else {
			//NSLog(@"%@",[resultdict keysSortedByValueUsingSelector:@selector(compareNumerically:)]);
			NSArray *tmpkeys = [resultdict allKeys];
			NSLog(@"%@", tmpkeys);
			tmpkeys = [tmpkeys sortedArrayUsingSelector:@selector(compareNumerically:)];
			NSLog(@"%@", tmpkeys);
			//tmptmp = [resultdict valueForKey:[tmpkeys objectAtIndex:0]];
			for (id key in tmpkeys) {
				[tmptmp addObject:[resultdict valueForKey:key]];
			}
			return [tmptmp autorelease];
		}
		
	} //else {
		//tmptmp = @"";
	//}
	return NULL;
}

- (void)textViewDidChange:(UITextView *)textView {
	NSLog(@"textViewDidChange %@", textView.text);
	//[outputString release];
	//outputString = [[NSMutableString alloc] initWithString:uiTextView.text];
	NSLog(@"location: %i, length = %i", [textView selectedRange].location, [textView selectedRange].length);
	if (chineseInput.on) {

	} 

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	NSLog(@"shouldChangeTextInRange , |||-%@-|||", text);
	NSLog(@"replacemne : %i, %i, %i", [text length], range.length, range.location);
	//selectIndex = textView.selectedRange.location;
	if (chineseInput.on) {
		if ([text length] > 0) {
			NSLog(@"1");
			//if (pending) {

			//} else {
				NSLog(@"4");
			
				if ([text characterAtIndex:0] == ' ') {
					if ([[mDefaultPrefs objectForKey:@"LastInputType"] isEqualToString:@"quick"]) {
						if (pending) {
							[self nextWaitingList:nil];
							return NO;
						}
					}
					NSLog(@"5");
					//NSLog(@"%@", [self getChineseWord:[newInputString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] withDict:dict]);
					if ([newInputString length] == 0) {
						NSLog(@"6");
						return YES ;
					}
					NSLog(@"%@", newInputString);
					NSMutableString *updateText = [[NSMutableString alloc] initWithString:textView.text];
					//NSString *word = [[self getChineseWord:[newInputString lowercaseString]] retain];
					NSArray *words = [[[self getChineseWord:[newInputString lowercaseString]] retain] autorelease];
					if (words == NULL) {
						[newInputString release];
						newInputString = [[NSMutableString alloc] init];
						uiTextField.text = [self parseString:newInputString];
						pending = NO;
						return NO;
					}
					if ([words count] >  1) {
						NSLog(@"7");
						[waitingList release];
						waitingList = [words copy];
						pending = YES;
						[self createChooseButtons];
						return NO;
					} else {
						NSLog(@"8");
						NSString *word;
						NSLog(@"%@" , words);
						if ([words count] > 0) {
							word = [words lastObject];
						}
						[updateText insertString:word atIndex:range.location];
						[newInputString release];
						newInputString = [[NSMutableString alloc] init];
						//[self getChineseWord:newInputString];
						textView.text = [updateText autorelease];
						NSRange endRange = NSMakeRange(range.location + [word length], 0);
						textView.selectedRange = endRange;
						//[words release];
						uiTextField.text = [self parseString:newInputString];
						pending = NO;
						return NO; //YES;
					}
					return NO;
				} else if ([text rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].length > 0) {
					if (!pending) {
						NSLog(@"9");
						if ([text length] > 1) {
							NSLog(@"%i", [text rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]].length);
							return YES;
						}
						NSLog(@"91");
						if ([text rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]].length == 0) {
							return YES;
						} 
						NSLog(@"92");
						if ([[mDefaultPrefs objectForKey:@"LastInputType"] isEqualToString:@"quick"]) {
							if ([newInputString length]<2) {
								[newInputString appendString:text];
								NSLog(@"%@", newInputString);
								uiTextField.text = [self parseString:newInputString];
							} 
							if ([newInputString length] == 2) {
								/////// This is for quick to get words;
								NSLog(@"%@", newInputString);
								//NSMutableString *updateText = [[NSMutableString alloc] initWithString:textView.text];
								//NSString *word = [[self getChineseWord:[newInputString lowercaseString]] retain];
								NSArray *words = [[[self getChineseWord:[newInputString lowercaseString]] retain] autorelease];
								if (words == NULL) {
									[newInputString release];
									newInputString = [[NSMutableString alloc] init];
									uiTextField.text = [self parseString:newInputString];
									pending = NO;
									return NO;
								}
								if ([words count] >  1) {
									NSLog(@"7");
									[waitingList release];
									waitingList = [words copy];
									pending = YES;
									[self createChooseButtons];
									return NO;
								}
							}

						} else {
							if ([newInputString length]<5) {
								[newInputString appendString:text];
								NSLog(@"%@", newInputString);
								uiTextField.text = [self parseString:newInputString];
							}
						}
					} else {
						NSLog(@"94");
						if ([[mDefaultPrefs objectForKey:@"LastInputType"] isEqualToString:@"quick"]) {
							return NO;
						}
						//if  word list but not choose use default 0 
						int index = 0;
						NSMutableString *updateText = [[NSMutableString alloc] initWithString:textView.text];
						NSLog(@"update text = %@", updateText);
						NSString *word = [waitingList objectAtIndex:MIN(MAX(0, index-1), [waitingList count]-1)];
						[updateText insertString:word atIndex:range.location];
						NSLog(@"%@ word", word);
						[newInputString release];
						newInputString = [[NSMutableString alloc] init];
						[self getChineseWord:newInputString];
						NSLog(@"update text = %@", updateText);
						textView.text = [updateText autorelease];
						NSRange endRange = NSMakeRange(range.location + [word length], 0);
						textView.selectedRange = endRange;
						//[words release];
						uiTextField.text = [self parseString:newInputString];
						pending = NO;
						[self removeButtons];
						
						//For new word
						[newInputString appendString:text];
						NSLog(@"%@", newInputString);
						uiTextField.text = [self parseString:newInputString];
						return NO;//YES;
					}
					NSLog(@"93");
					return NO;
				} else if ([text rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].length > 0) {
					NSLog(@"2");
					if (pending == YES) {
						int index = [[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] intValue];
						NSMutableString *updateText = [[NSMutableString alloc] initWithString:textView.text];
						NSLog(@"update text = %@", updateText);
						NSString *word = [waitingList objectAtIndex:MIN(MAX(0, 9*waitingListIndex+index-1), [waitingList count]-1)];
						[updateText insertString:word atIndex:range.location];
						NSLog(@"%@ word", word);
						[newInputString release];
						newInputString = [[NSMutableString alloc] init];
						//[self getChineseWord:newInputString];
						NSLog(@"update text = %@", updateText);
						textView.text = [updateText autorelease];
						NSRange endRange = NSMakeRange(range.location + [word length], 0);
						textView.selectedRange = endRange;
						//[words release];
						uiTextField.text = [self parseString:newInputString];
						pending = NO;
						[self removeButtons];
						waitingListIndex = 0;
						return NO;//YES;
					} else {
						NSLog(@"3");
						return YES;
					}
				} else {
					return YES;
				}
			//}
		} else {
			//back space
			NSLog(@"13");
			if ([newInputString length] > 0) {
				pending = NO;
				NSLog(@"14");
				NSLog(@"%@", newInputString);
				[newInputString deleteCharactersInRange:NSMakeRange([newInputString length]-1, 1)];
				uiTextField.text = [self parseString:newInputString];
				NSLog(@"%@", newInputString);
				[self removeButtons];
				return NO;
			}
			NSLog(@"15");
			return YES;
		}
	} else {
		return YES;
	}
	return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	NSLog(@"textViewDidBeginEditing");
}
- (void)textViewDidChangeSelection:(UITextView *)textView {
	NSLog(@"textViewDidChangeSelection %@", textView.text);
	//selectIndex = [textView selectedRange].location;
	NSLog(@"location: %i %i", [textView selectedRange].location, [textView selectedRange].length);
	//[textView ]
	//chineseInput.on = NO;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	NSLog(@"textViewDidEndEditing");
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	NSLog(@"textViewShouldBeginEditing");
	return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	NSLog(@"textViewShouldEndEditing");
    return YES;
}

- (IBAction)nextWaitingList:(id)sender {
	waitingListIndex++;
	NSLog(@"%i %i", [waitingList count], waitingListIndex * 9);
	if (([waitingList count] <= (waitingListIndex*9))) {
		NSLog(@"%i ", waitingListIndex * 9);
		waitingListIndex = 0;
	}
	[self removeButtons];
	[self createChooseButtons];
}

- (void)createChooseButtons {
	NSLog(@"createChooseButtons1");
	if (waitingList) {
		
		if ([waitingList count] > 9) {
			int position = 0;
			NSLog(@"watitng index %i",  waitingListIndex);
			for (int i = 0; i<MIN([waitingList count]-(9*waitingListIndex),9); i++) {
				NSLog(@"createChooseButtons4");
				UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				//[[UIButton alloc] initWithFrame:CGRectMake(119+(i*80), 61, 72, 37)];
				button.frame = CGRectMake(position=20+(i*74), 53, 63, 37); //CGRectMake(20+(i*51), 61, 50, 20);
				[button setTitle:[NSString stringWithFormat:@"%i: %@", (i+1), [waitingList objectAtIndex:waitingListIndex*9+i]] forState:UIControlStateNormal];
				[button addTarget:self action:@selector(chooseWord:) forControlEvents:UIControlEventTouchDown];
				//[self.view addSubview:button];
				[inputPanel addSubview:button];
				[button setHidden:NO];
				[button setNeedsDisplay];
				[buttons addObject:button];
			}
			UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			button.frame = CGRectMake(position+74, 53, 63, 37);
			[button setTitle:@">" forState:UIControlStateNormal];
			[button addTarget:self action:@selector(nextWaitingList:) forControlEvents:UIControlEventTouchDown];
			[inputPanel addSubview:button];
			[button setHidden:NO];
			[button setNeedsDisplay];
			[buttons addObject:button];
			
		} else {
			NSLog(@"createChooseButtons2");
			for (int i = 0; i<[waitingList count]; i++) {
				NSLog(@"createChooseButtons3");
				UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
				//[[UIButton alloc] initWithFrame:CGRectMake(119+(i*80), 61, 72, 37)];
				button.frame = CGRectMake(20+(i*74), 53, 63, 37); //CGRectMake(20+(i*51), 61, 50, 20);
				[button setTitle:[NSString stringWithFormat:@"%i: %@", (i+1), [waitingList objectAtIndex:i]] forState:UIControlStateNormal];
				[button addTarget:self action:@selector(chooseWord:) forControlEvents:UIControlEventTouchDown];
				//[self.view addSubview:button];
				[inputPanel addSubview:button];
				[button setHidden:NO];
				[button setNeedsDisplay];
				[buttons addObject:button];
			}
		}
		[self.view setNeedsDisplay];
	}
	NSLog(@"%@", buttons);
}

- (void)chooseWord:(id)sender {
	UIButton *button = sender;
	int index = [[button.titleLabel.text substringWithRange:NSMakeRange(0, 1)] intValue];
	NSMutableString *updateText = [[NSMutableString alloc] initWithString:uiTextView.text];
	NSLog(@"update text = %@", updateText);
	NSString *word = [waitingList objectAtIndex:MIN(MAX(0, 9*waitingListIndex+index-1), [waitingList count]-1)];
	NSRange range = [uiTextView selectedRange];
	[updateText insertString:word atIndex:range.location];
	NSLog(@"%@ word", word);
	[newInputString release];
	newInputString = [[NSMutableString alloc] init];
	//[self getChineseWord:newInputString];
	NSLog(@"update text = %@", updateText);
	uiTextView.text = [updateText autorelease];
	NSRange endRange = NSMakeRange(range.location + [word length], 0);
	uiTextView.selectedRange = endRange;
	//[words release];
	uiTextField.text = [self parseString:newInputString] ;
	pending = NO;
	[self removeButtons];
	waitingListIndex = 0;
}

- (void)removeButtons {
	for (UIButton *tmpbutton in buttons) {
		tmpbutton.hidden = YES;
		[tmpbutton setNeedsDisplay];
		[tmpbutton removeFromSuperview];
	}
	[self.view setNeedsDisplay];
	[buttons removeAllObjects];
}

- (NSString *)parseString:(NSString *)string {
	if (orgCharDict) {
		NSMutableString *newString = [NSMutableString string];
		for (int i = 0; i < [string length]; i++) {
			[newString appendString:[orgCharDict objectForKey:[NSString stringWithFormat:@"%c", [string characterAtIndex:i]]]];
		}
		return newString;
	} else {
		return string;
	}
}

- (IBAction)copyAll:(id)sender {
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	[pasteboard setValue:uiTextView.text forPasteboardType:@"public.utf8-plain-text"];
}

- (IBAction)switchType:(id)sender {
	inputIndex = (inputIndex + 1) % 3;
	
	switch (inputIndex) {
		case 0: {
			[keydict release];
			keydict = [cangjie3Dict retain];
			[mDefaultPrefs setObject:@"changie3" forKey:@"LastInputType"];
			[inputTypeButton setTitle:@"\u5009\u4e09" forState:UIControlStateNormal];
		}
			break;
		case 1: {
			[keydict release];
			keydict = [cangjie5Dict retain];
			[mDefaultPrefs setObject:@"changie5" forKey:@"LastInputType"];
			[inputTypeButton setTitle:@"\u5009\u4e94" forState:UIControlStateNormal];
		}
			break;
		case 2: {
			[keydict release];
			keydict = [quickDict retain];
			[mDefaultPrefs setObject:@"quick" forKey:@"LastInputType"];
			[inputTypeButton setTitle:@"\u901f\u6210" forState:UIControlStateNormal];
		}
			break;
		default:
			break;
	}
	[self removeButtons];
	waitingListIndex = 0;
	[newInputString release];
	newInputString = [[NSMutableString alloc] init];
	uiTextField.text = [self parseString:newInputString];
	pending = NO;

}

- (IBAction)callSetting:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:?subject=trst&body=aaa"]];
	
}

- (IBAction)callGoogle:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/search?q=%@", uiTextView.text]]];
}

- (IBAction)callEmail:(id)sender {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:?body=%@", uiTextView.text]]];
}

- (void)keyboardWillShow:(NSNotification *)note {
	NSLog(@"Keyboard Will Show %@", [note userInfo]);
	NSDictionary *userInfo = [note userInfo];
	//NSValue *keyBounds = [info objectForKey:UIKeyboardFrameEndUserInfoKey];

	NSTimeInterval animationDuration;
	UIViewAnimationCurve animationCurve;
	
	CGRect keyboardEndFrame;
	
	[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	
	
	[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
	
	NSLog(@"%@", [[UIApplication sharedApplication] windows]);
	UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
	NSLog(@"%@", tempWindow);
	//NSLog(@"%@", [tempWindow ]);
	UIView* keyboard=[self inputView];
	NSLog(@"%@", keyboard);

	//[UIView beginAnimations:@"MoveAndStrech" context:nil];
	//[UIView setAnimationDuration:animationDuration];
	//[UIView setAnimationBeginsFromCurrentState:animationCurve];
	
	//[inputPanel setFrame:CGRectMake(0, 1024, logoView.frame.size.width, 100)];
	//[inputPanel setFrame:CGRectMake(0, keyboardEndFrame.origin.y-100, logoView.frame.size.width, 100)];
	//[UIView commitAnimations];
	
	//[inputPanel setFrame:CGRectMake(0, keyboardEndFrame.origin.y-100, logoView.frame.size.width, 100)];
	//[tempWindow addSubview:inputPanel];
	//[tempWindow setNeedsDisplay];
	//[mainView addSubview:inputPanel];
	//[mainView setNeedsDisplay];
	[inputPanel setHidden:NO];
	[inputPanel setNeedsDisplay];
}

- (void)buttonClicked:(NSNotification *)note
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You clicked the keyboard button!" message:@"Hey!  You clicked the button on top of the keyboard." delegate:self cancelButtonTitle:@"Yep" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)keyboardDidHide:(NSNotification *)note {
	NSLog(@"KeyBoard did hide% @", [note userInfo]);
	//NSDictionary *userInfo = [note userInfo];
	//NSValue *keyBounds = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	
	//NSTimeInterval animationDuration;
	//UIViewAnimationCurve animationCurve;
	
	//CGRect keyboardEndFrame;
	//[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	//[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	
	
	//[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
	//UIWindow *tempwindow = inputPanel.window;
	//[inputPanel ]
	//[UIView beginAnimations:@"MoveAndStrech" context:nil];
	//[UIView setAnimationDuration:1];
	//[UIView setAnimationBeginsFromCurrentState:animationCurve];
	
	//[inputPanel setFrame:CGRectMake(0, keyboardEndFrame.origin.y-100, logoView.frame.size.width, 100)];
	//[inputPanel setFrame:CGRectMake(0, 1024, logoView.frame.size.width, 100)];

	//[UIView commitAnimations];
	//[inputPanel removeFromSuperview];
	//[tempwindow setNeedsDisplay];
	[inputPanel setHidden:YES];
	[inputPanel setNeedsDisplay];
}

- (void)dealloc {
	[mDefaultPrefs autorelease];
	[keydict autorelease];
	[inputString autorelease];
	[outputString autorelease];
	[waitingList autorelease];
	[cangjie3Dict autorelease];
	[cangjie5Dict autorelease];
	[quickDict autorelease];
	[orgCharDict autorelease];
	[buttons autorelease];
    [super dealloc];
}

@end

@implementation NSString (numericComparison)

- (NSComparisonResult) compareNumerically:(NSString *) other
{
	NSLog(@"self = |%@|, other = |%@|", self, other);
	int myValue = [self intValue];
	int otherValue = [other intValue];
	if (myValue == otherValue) return NSOrderedSame;
	return (myValue > otherValue ? NSOrderedAscending : NSOrderedDescending);
}

@end

//@implementation UITextView (pasteboard)
//-(void) paste:(id)sender{
//	NSLog(@"paste button was pressed do something");
//}
//@end
