//
//  LostPetDetailTableCell.m
//  ThingsAboutAnimals
//
//  Created by Wayne on 4/7/15.
//  Copyright (c) 2015 Wayne. All rights reserved.
//

#import "LostPetDetailTableCell.h"
#import "MarqueeLabel.h"
#import "LostPet.h"
#import <WebKit/WebKit.h>

@interface LostPetDetailTableCell()
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *varietyNSex;
@property (weak, nonatomic) IBOutlet UILabel *race;
@property (weak, nonatomic) IBOutlet MarqueeLabel *chipNumber;
@property (weak, nonatomic) IBOutlet MarqueeLabel *hairColor;
@property (weak, nonatomic) IBOutlet MarqueeLabel *hairStyle;
@property (weak, nonatomic) IBOutlet UILabel *lostDate;
@property (weak, nonatomic) IBOutlet UILabel *lostPlace;
@property (weak, nonatomic) IBOutlet UILabel *ownersName;
@property (weak, nonatomic) IBOutlet UILabel *phoneNEmail;
@property (weak, nonatomic) IBOutlet UITextView *characterized;

//@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
//- (void)panInView:(UIPanGestureRecognizer *)recognizer;
@end

@implementation LostPetDetailTableCell

- (void)awakeFromNib {
    
//    if (!self.panGesture) {
//        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInView:)];
//        [self addGestureRecognizer:self.panGesture];
//    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)settingContentsByLostPet:(LostPet *)lostPet {
    if (!self.lostPet) {
        self.lostPet = lostPet;
    }
    self.characterized.layer.cornerRadius = 5.0f;
    self.characterized.layer.masksToBounds = YES;
    
    self.name.text = self.lostPet.name?self.lostPet.name:@"";
    self.varietyNSex.text = [NSString stringWithFormat:@"%@ / %@",
                             (self.lostPet.variety && ![self.lostPet.variety isEqualToString:@""])?self.lostPet.variety:@"-",
                             self.lostPet.gender?self.lostPet.gender:@"-"];
    self.race.text = self.lostPet.race?self.lostPet.race:@"";
    self.chipNumber.text = self.lostPet.chipNumber?self.lostPet.chipNumber:@"";
    self.hairColor.text = self.lostPet.hairColor?self.lostPet.hairColor:@"";
    self.hairStyle.text = self.lostPet.hairStyle?self.lostPet.hairStyle:@"";
    self.lostDate.text = self.lostPet.lostDate?self.lostPet.lostDate:@"";
    self.lostPlace.text = self.lostPet.lostPlace?self.lostPet.lostPlace:@"";
    self.ownersName.text = self.lostPet.ownersName?self.lostPet.ownersName:@"";
    self.phoneNEmail.text = [NSString stringWithFormat:@"%@ / %@",
                             (self.lostPet.phone && ![self.lostPet.phone isEqualToString:@""])?self.lostPet.phone:@"-",
                             (self.lostPet.email && ![self.lostPet.email isEqualToString:@""])?self.lostPet.email:@"-"];
    self.characterized.text = self.lostPet.characterized?self.lostPet.characterized:@"";
}

//- (void)panInView:(UIPanGestureRecognizer *)recognizer {
//    CGPoint touchPoint = [recognizer locationInView:self];
//    if (CGRectContainsPoint(self.lostPetCollectionViewCell.upperViewContainer.frame, touchPoint)) {
//        NSLog(@"ok");
//    }
//}
@end
