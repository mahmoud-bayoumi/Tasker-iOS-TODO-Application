//
//  TaskTableViewCell.m
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//

#import "TaskTableViewCell.h"

@implementation TaskTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.priorityImageView.layer.cornerRadius = 15;

}

- (void)configureWithTask:(Task *)task {
    

    self.nameLabel.text = task.name;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM dd, yyyy";
    NSString *dateStr = [formatter stringFromDate:task.createdDate];
    
    NSMutableString *info = [NSMutableString stringWithFormat:@"%@", dateStr]; //     NSMutableString *info = [NSMutableString stringWithFormat:@"📅 %@", dateStr];

    if (task.attachedFilePath) [info appendString:@"  "];
    if (task.reminderDate)     [info appendString:@"  "];
    self.dateLabel.text = info;
    
    switch (task.priority) {
        case TaskPriorityHigh:
            self.priorityImageView.image = [UIImage systemImageNamed:@"flame.fill"];
            self.priorityImageView.tintColor = [UIColor systemRedColor];
            self.priorityImageView.backgroundColor =
                [[UIColor systemRedColor] colorWithAlphaComponent:0.15];
            break;
        case TaskPriorityMedium:
            self.priorityImageView.image = [UIImage systemImageNamed:@"bolt.fill"];
            self.priorityImageView.tintColor = [UIColor systemOrangeColor];
            self.priorityImageView.backgroundColor =
                [[UIColor systemOrangeColor] colorWithAlphaComponent:0.15];
            break;
        case TaskPriorityLow:
            self.priorityImageView.image = [UIImage systemImageNamed:@"leaf.fill"];
            self.priorityImageView.tintColor = [UIColor systemGreenColor];
            self.priorityImageView.backgroundColor =
                [[UIColor systemGreenColor] colorWithAlphaComponent:0.15];
            break;
    }
    self.priorityImageView.contentMode = UIViewContentModeCenter;
    
}

@end
