//
//  TaskTableViewCell.h
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//

#import <UIKit/UIKit.h>
#import "Task.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaskTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *priorityImageView;

- (void)configureWithTask:(Task *)task;

@end

NS_ASSUME_NONNULL_END
