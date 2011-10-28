//
//  BoardVC.h
//  CifrasSinLetras
//
//  Created by Delgado Molina Ismael on 22/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoardVC : UIViewController <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UIButton *vowelButton;
@property (weak, nonatomic) IBOutlet UIButton *consonantButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIProgressView *restTimeProgressView;
@property (weak, nonatomic) IBOutlet UILabel *restTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *letter1;
@property (weak, nonatomic) IBOutlet UIButton *letter2;
@property (weak, nonatomic) IBOutlet UIButton *letter3;
@property (weak, nonatomic) IBOutlet UIButton *letter4;
@property (weak, nonatomic) IBOutlet UIButton *letter5;
@property (weak, nonatomic) IBOutlet UIButton *letter6;
@property (weak, nonatomic) IBOutlet UIButton *letter7;
@property (weak, nonatomic) IBOutlet UIButton *letter8;
@property (weak, nonatomic) IBOutlet UIButton *letter9;

@property (strong, nonatomic) NSArray *letters;
@property (strong, nonatomic) NSString *answer;
@property (strong, nonatomic) NSMutableDictionary *achievementsDictionary;

- (IBAction)addVowel:(id)sender;
- (IBAction)addConsonant:(id)sender;
- (IBAction)endMatch:(id)sender;
- (IBAction)useLetter:(id)sender;
- (IBAction)clearAnswer:(id)sender;

@end
