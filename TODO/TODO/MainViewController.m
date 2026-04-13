//
//  ViewController.m
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//

#import "MainViewController.h"
#import "Task.h"
#import "TaskManager.h"
#import "TaskTableViewCell.h"
#import "TaskDetailViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *emptyStateImageView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *emptyStateView;

@property (nonatomic, strong) UIView *savedEmptyStateView;

@property (nonatomic, strong) NSArray<Task *> *filteredTasks;
@property (nonatomic, strong) NSString *searchText;

@property (nonatomic, strong) NSArray<Task *> *highTasks;
@property (nonatomic, strong) NSArray<Task *> *medTasks;
@property (nonatomic, strong) NSArray<Task *> *lowTasks;

@end

@implementation MainViewController



- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.segmentedControl.apportionsSegmentWidthsByContent = YES;

    [self.tableView registerNib:[UINib nibWithNibName:@"TaskTableViewCell"
                                               bundle:nil]
         forCellReuseIdentifier:@"TaskCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 90;
    
    self.savedEmptyStateView = self.tableView.tableFooterView;
    
    self.searchText = @"";
    self.segmentedControl.selectedSegmentIndex = 0;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self applyFilters];
    [self.tableView reloadData];
}

- (void)applyFilters {
    
    NSArray *allTasks = [TaskManager sharedManager].tasks;
    
    if (self.searchText.length > 0) {
        NSPredicate *searchPred = [NSPredicate predicateWithFormat:
                                   @"name CONTAINS[cd] %@", self.searchText];
        allTasks = [allTasks filteredArrayUsingPredicate:searchPred];
    }
    
    NSInteger segment = self.segmentedControl.selectedSegmentIndex;
    
    switch (segment) {
        case 0:
            self.filteredTasks = allTasks;
            break;
        case 1:
            self.filteredTasks = [allTasks filteredArrayUsingPredicate:
                [NSPredicate predicateWithFormat:@"status == %d", TaskStatusToDo]];
            break;
        case 2:
            self.filteredTasks = [allTasks filteredArrayUsingPredicate:
                [NSPredicate predicateWithFormat:@"status == %d", TaskStatusInProgress]];
            break;
        case 3:
            self.filteredTasks = [allTasks filteredArrayUsingPredicate:
                [NSPredicate predicateWithFormat:@"status == %d", TaskStatusDone]];
            break;
        case 4:
            self.highTasks = [allTasks filteredArrayUsingPredicate:
                [NSPredicate predicateWithFormat:@"priority == %d", TaskPriorityHigh]];
            self.medTasks = [allTasks filteredArrayUsingPredicate:
                [NSPredicate predicateWithFormat:@"priority == %d", TaskPriorityMedium]];
            self.lowTasks = [allTasks filteredArrayUsingPredicate:
                [NSPredicate predicateWithFormat:@"priority == %d", TaskPriorityLow]];
            self.filteredTasks = allTasks;
            break;
    }
    
    [self updateEmptyState];
}

- (void)updateEmptyState {
    BOOL isEmpty;
    
    if ([self isPriorityMode]) {
        isEmpty = (self.highTasks.count + self.medTasks.count + self.lowTasks.count) == 0;
    } else {
        isEmpty = (self.filteredTasks.count == 0);
    }
    
    if (isEmpty) {
        self.tableView.tableFooterView = self.savedEmptyStateView;
        self.emptyStateImageView.image = [UIImage imageNamed:@"task_image"];
    } else {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
}

- (BOOL)isPriorityMode {
    return self.segmentedControl.selectedSegmentIndex == 4;
}


- (IBAction)segmentedAction:(UISegmentedControl *)sender {
    [self applyFilters];
    [self.tableView reloadData];
}

- (IBAction)addTaskTapped:(id)sender {
    UIViewController *addVC = [self.storyboard
        instantiateViewControllerWithIdentifier:@"AddTaskViewController"];
    if (addVC) {
        [self.navigationController pushViewController:addVC animated:YES];
    } else {
        NSLog(@"AddTaskViewController not found in storyboard yet");
    }
}


- (Task *)taskForIndexPath:(NSIndexPath *)indexPath {
    if ([self isPriorityMode]) {
        switch (indexPath.section) {
            case 0: return self.highTasks[indexPath.row];
            case 1: return self.medTasks[indexPath.row];
            case 2: return self.lowTasks[indexPath.row];
            default: return nil;
        }
    }
    return self.filteredTasks[indexPath.row];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self isPriorityMode]) return 3;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if ([self isPriorityMode]) {
        switch (section) {
            case 0: return self.highTasks.count;
            case 1: return self.medTasks.count;
            case 2: return self.lowTasks.count;
            default: return 0;
        }
    }
    return self.filteredTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TaskTableViewCell *cell = [tableView
        dequeueReusableCellWithIdentifier:@"TaskCell"
                             forIndexPath:indexPath];
    
    Task *task = [self taskForIndexPath:indexPath];
    [cell configureWithTask:task];
    
    return cell;
}



- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
    
    if (![self isPriorityMode]) return nil;
    
    UIView *header = [[UIView alloc] init];
    
    UIImageView *icon = [[UIImageView alloc] init];
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    icon.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont boldSystemFontOfSize:16];
    
    switch (section) {
        case 0:
            header.backgroundColor = [[UIColor systemRedColor]
                                       colorWithAlphaComponent:0.1];
            icon.image = [UIImage systemImageNamed:@"flame.fill"];
            icon.tintColor = [UIColor systemRedColor];
            label.text = @"High Priority";
            label.textColor = [UIColor systemRedColor];
            break;
        case 1:
            header.backgroundColor = [[UIColor systemOrangeColor]
                                       colorWithAlphaComponent:0.1];
            icon.image = [UIImage systemImageNamed:@"bolt.fill"];
            icon.tintColor = [UIColor systemOrangeColor];
            label.text = @"Medium Priority";
            label.textColor = [UIColor systemOrangeColor];
            break;
        case 2:
            header.backgroundColor = [[UIColor systemGreenColor]
                                       colorWithAlphaComponent:0.1];
            icon.image = [UIImage systemImageNamed:@"leaf.fill"];
            icon.tintColor = [UIColor systemGreenColor];
            label.text = @"Low Priority";
            label.textColor = [UIColor systemGreenColor];
            break;
    }
    
    [header addSubview:icon];
    [header addSubview:label];
    
    [NSLayoutConstraint activateConstraints:@[
        [icon.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [icon.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [icon.widthAnchor constraintEqualToConstant:20],
        [icon.heightAnchor constraintEqualToConstant:20],
        [label.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:8],
        [label.centerYAnchor constraintEqualToAnchor:header.centerYAnchor]
    ]];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    if ([self isPriorityMode]) return 44;
    return 0;
}


- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Task *task = [self taskForIndexPath:indexPath];
    
    UIViewController *detailVC = [self.storyboard
        instantiateViewControllerWithIdentifier:@"TaskDetailViewController"];
    
    if (detailVC) {
        [detailVC setValue:task forKey:@"task"];
        [self.navigationController pushViewController:detailVC animated:YES];
    } else {
        NSLog(@"TaskDetailViewController not found in storyboard yet");
    }
}



- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
    trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIContextualAction *deleteAction = [UIContextualAction
        contextualActionWithStyle:UIContextualActionStyleDestructive
                            title:@"Delete"
                          handler:^(UIContextualAction *action,
                                    UIView *sourceView,
                                    void (^completionHandler)(BOOL)) {
        
        Task *task = [self taskForIndexPath:indexPath];
        
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Delete Task?"
            message:[NSString stringWithFormat:
                @"\"%@\" will be permanently removed.", task.name]
            preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
            style:UIAlertActionStyleCancel
            handler:^(UIAlertAction *a) {
                completionHandler(NO);
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Delete"
            style:UIAlertActionStyleDestructive
            handler:^(UIAlertAction *a) {
                [[TaskManager sharedManager] removeTask:task];
                [self applyFilters];
                [self.tableView reloadData];
                completionHandler(YES);
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    deleteAction.image = [UIImage systemImageNamed:@"trash"];
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
}



- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView
    leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIContextualAction *editAction = [UIContextualAction
        contextualActionWithStyle:UIContextualActionStyleNormal
                            title:@"Edit"
                          handler:^(UIContextualAction *action,
                                    UIView *sourceView,
                                    void (^completionHandler)(BOOL)) {
        
        Task *task = [self taskForIndexPath:indexPath];
        
        UIViewController *editVC = [self.storyboard
            instantiateViewControllerWithIdentifier:@"TaskDetailViewController"];
        if (editVC) {
            [editVC setValue:task forKey:@"task"];
            [self.navigationController pushViewController:editVC animated:YES];
        }
        completionHandler(YES);
    }];
    
    editAction.backgroundColor = [UIColor systemBlueColor];
    editAction.image = [UIImage systemImageNamed:@"pencil"];
    return [UISwipeActionsConfiguration configurationWithActions:@[editAction]];
}



- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    
    self.searchText = [searchText stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self applyFilters];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    self.searchText = @"";
    [searchBar resignFirstResponder];
    [self applyFilters];
    [self.tableView reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

@end
