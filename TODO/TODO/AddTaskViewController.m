//
//  AddTaskViewController.m
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//

#import "AddTaskViewController.h"
#import "Task.h"
#import "TaskManager.h"

@interface AddTaskViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UILabel *dateText;
@property (weak, nonatomic) IBOutlet UILabel *timeText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegment;

@property (nonatomic, assign) TaskPriority selectedPriority;

@end

@implementation AddTaskViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add New Task";
    
    self.selectedPriority = TaskPriorityLow;
    self.prioritySegment.selectedSegmentIndex = 0;
    
    [self setupDateTime];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:@"Cancel"
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(cancelTapped)];
    
}


- (void)setupDateTime {
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"MMM dd, yyyy";
    self.dateText.text = [dateFmt stringFromDate:now];
    
    NSDateFormatter *timeFmt = [[NSDateFormatter alloc] init];
    timeFmt.dateFormat = @"hh:mm a";
    self.timeText.text = [timeFmt stringFromDate:now];
}


- (IBAction)prioritySegmentAction:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.selectedPriority = TaskPriorityLow;
            break;
        case 1:
            self.selectedPriority = TaskPriorityMedium;
            break;
        case 2:
            self.selectedPriority = TaskPriorityHigh;
            break;
        default:
            self.selectedPriority = TaskPriorityLow;
            break;
    }
}


- (IBAction)addTask:(id)sender {
    
    NSString *name = [self.titleTextField.text
        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (name.length == 0) {
        
        self.titleTextField.layer.borderWidth = 1.0;
        self.titleTextField.layer.borderColor = [UIColor systemRedColor].CGColor;
        self.titleTextField.layer.cornerRadius = 6;
     
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Missing Task Name"
            message:@"Please enter a name for your task."
            preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction
            actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault
            handler:^(UIAlertAction *action) {
                [self.titleTextField becomeFirstResponder];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.titleTextField.layer.borderWidth = 0;
    
    Task *task = [[Task alloc] init];
    task.name = name;
    task.taskDescription = self.descriptionTextField.text ?: @"";
    task.priority = self.selectedPriority;
    task.status = TaskStatusToDo;
    
    [[TaskManager sharedManager] addTask:task];
    
    NSLog(@"Task Created: %@ | Priority: %ld | Status: To-Do",
          task.name, (long)task.priority);
    
    UIAlertController *success = [UIAlertController
        alertControllerWithTitle:@"Task Created! ✓"
        message:[NSString stringWithFormat:@"\"%@\" has been added to your list.", name]
        preferredStyle:UIAlertControllerStyleAlert];
    
    [success addAction:[UIAlertAction
        actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:success animated:YES completion:nil];
}


- (void)cancelTapped {
    
    BOOL hasTitle = (self.titleTextField.text.length > 0);
    BOOL hasDesc  = (self.descriptionTextField.text.length > 0);
    
    if (hasTitle || hasDesc) {
        // User has unsaved content so confirm discard
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Discard Task?"
            message:@"You have unsaved changes. Are you sure?"
            preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction
            actionWithTitle:@"Keep Editing"
            style:UIAlertActionStyleCancel
            handler:nil]];
        
        [alert addAction:[UIAlertAction
            actionWithTitle:@"Discard"
            style:UIAlertActionStyleDestructive
            handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
