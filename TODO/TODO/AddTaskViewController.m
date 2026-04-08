//
//  AddTaskViewController.m
//  TODO
//
//  Created by Bayoumi on 07/04/2026.
//
#import "AddTaskViewController.h"
#import "Task.h"
#import "TaskManager.h"
#import <UserNotifications/UserNotifications.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface AddTaskViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegment;

@property (weak, nonatomic) IBOutlet UIDatePicker *reminderDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *reminderAtLabel;

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;

@property (nonatomic, assign) TaskPriority selectedPriority;
@property (nonatomic, assign) BOOL reminderSet;
@property (nonatomic, strong) NSDate *originalPickerDate;
@property (nonatomic, strong) NSString *attachedFilePath;
@property (nonatomic, strong) NSString *attachedFileName;

@end

@implementation AddTaskViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add New Task";
    
    self.selectedPriority = TaskPriorityLow;
    self.prioritySegment.selectedSegmentIndex = 0;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:@"Cancel"
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(cancelTapped)];
    
    self.reminderDatePicker.date = [NSDate date];
    self.reminderDatePicker.minimumDate = [NSDate date];
    self.reminderDatePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.reminderDatePicker.hidden = NO;
    self.originalPickerDate = self.reminderDatePicker.date;
    
    [self.reminderDatePicker addTarget:self
                                action:@selector(datePickerChanged:)
                      forControlEvents:UIControlEventValueChanged];
    
    self.reminderSet = NO;
    self.reminderAtLabel.hidden = YES;
    
    self.attachedFilePath = nil;
    self.attachedFileName = nil;
    self.fileNameLabel.hidden = YES;
    
    [self requestNotificationPermission];
    
    NSLog(@"AddTaskViewController loaded");
}



- (IBAction)prioritySegmentAction:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0: self.selectedPriority = TaskPriorityLow; break;
        case 1: self.selectedPriority = TaskPriorityMedium; break;
        case 2: self.selectedPriority = TaskPriorityHigh; break;
        default: self.selectedPriority = TaskPriorityLow; break;
    }
}


- (void)datePickerChanged:(UIDatePicker *)picker {
    self.reminderSet = YES;
    [self updateReminderLabel];
    self.reminderAtLabel.hidden = NO;
}

- (void)updateReminderLabel {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"MMM dd, yyyy 'at' hh:mm a";
    fmt.timeZone = [NSTimeZone localTimeZone];
    self.reminderAtLabel.text = [NSString stringWithFormat:
        @"Reminder: %@", [fmt stringFromDate:self.reminderDatePicker.date]];
}

- (IBAction)removeReminderAction:(id)sender {
    self.reminderSet = NO;
    self.reminderAtLabel.hidden = YES;
    self.reminderDatePicker.date = [NSDate date];
    self.originalPickerDate = self.reminderDatePicker.date;
    NSLog(@"Reminder removed");
}

- (IBAction)setReminderAction:(id)sender {
    self.reminderSet = YES;
    [self updateReminderLabel];
    self.reminderAtLabel.hidden = NO;
}


- (void)requestNotificationPermission {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert |
                                             UNAuthorizationOptionSound |
                                             UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError *error) {
        if (granted) {
            NSLog(@"Notification permission granted");
        }
    }];
}

- (void)scheduleReminderNotification:(Task *)task {
    if (!task.reminderDate) return;
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Task Reminder";
    content.body = [NSString stringWithFormat:@"Don't forget: %@", task.name];
    content.sound = [UNNotificationSound defaultSound];
    
    NSDateComponents *components = [[NSCalendar currentCalendar]
        components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                    NSCalendarUnitHour | NSCalendarUnitMinute)
          fromDate:task.reminderDate];
    
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger
        triggerWithDateMatchingComponents:components repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest
        requestWithIdentifier:task.taskID content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter]
        addNotificationRequest:request withCompletionHandler:^(NSError *error) {
        if (!error) {
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            fmt.dateFormat = @"MMM dd, yyyy 'at' hh:mm a";
            fmt.timeZone = [NSTimeZone localTimeZone];
            NSLog(@"Reminder scheduled for: %@ (local time)",
                  [fmt stringFromDate:task.reminderDate]);
        }
    }];
}


- (IBAction)attachFileAction:(id)sender {
    
    UIAlertController *sheet = [UIAlertController
        alertControllerWithTitle:@"Attach File"
        message:@"Choose a source"
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    [sheet addAction:[UIAlertAction
        actionWithTitle:@"Choose Document"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self openDocumentPicker];
    }]];
    
    [sheet addAction:[UIAlertAction
        actionWithTitle:@"Choose Photo"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self openPhotoPicker];
    }]];
    
    [sheet addAction:[UIAlertAction
        actionWithTitle:@"Cancel"
        style:UIAlertActionStyleCancel
        handler:nil]];
    
    [self presentViewController:sheet animated:YES completion:nil];
}



- (void)openDocumentPicker {
    NSArray *types = @[UTTypeItem, UTTypePDF, UTTypeImage, UTTypePlainText];
    
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initForOpeningContentTypes:types];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller
    didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    
    NSURL *url = urls.firstObject;
    if (!url) return;
    
    [url startAccessingSecurityScopedResource];
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileName = url.lastPathComponent;
    NSString *destPath = [docsPath stringByAppendingPathComponent:fileName];
    
    [[NSFileManager defaultManager] removeItemAtPath:destPath error:nil];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtURL:url
        toURL:[NSURL fileURLWithPath:destPath] error:&error];
    
    [url stopAccessingSecurityScopedResource];
    
    if (!error) {
        [self fileAttachedWithPath:destPath fileName:fileName];
    } else {
        NSLog(@"File copy error: %@", error.localizedDescription);
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"Document picker cancelled");
}


- (void)openPhotoPicker {
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Not Available"
            message:@"Photo library is not available."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
            style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (!image) return;
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileName = [NSString stringWithFormat:@"photo_%@.jpg",
        [[NSUUID UUID] UUIDString]];
    NSString *destPath = [docsPath stringByAppendingPathComponent:fileName];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    BOOL success = [imageData writeToFile:destPath atomically:YES];
    
    if (success) {
        [self fileAttachedWithPath:destPath fileName:fileName];
    } else {
        NSLog(@"Failed to save photo");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)fileAttachedWithPath:(NSString *)path fileName:(NSString *)name {
    
    if (self.attachedFilePath) {
        [[NSFileManager defaultManager] removeItemAtPath:self.attachedFilePath error:nil];
    }
    
    self.attachedFilePath = path;
    self.attachedFileName = name;
    
    self.fileNameLabel.text = [NSString stringWithFormat:@"%@", name];
    self.fileNameLabel.hidden = NO;
    
    NSLog(@"File attached: %@", name);
}

- (IBAction)removeFileAction:(id)sender {
    
    if (self.attachedFilePath) {
        [[NSFileManager defaultManager] removeItemAtPath:self.attachedFilePath error:nil];
    }
    
    self.attachedFilePath = nil;
    self.attachedFileName = nil;
    
    self.fileNameLabel.hidden = YES;
    
    NSLog(@"File removed");
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
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
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
    
    if (self.reminderSet) {
        task.reminderDate = self.reminderDatePicker.date;
    } else {
        task.reminderDate = nil;
    }
    
    if (self.attachedFilePath) {
        task.attachedFilePath = self.attachedFilePath;
        task.attachedFileName = self.attachedFileName;
    }
    
    [[TaskManager sharedManager] addTask:task];
    
    if (self.reminderSet) {
        [self scheduleReminderNotification:task];
    }
    
    NSLog(@"Task Created: %@ | Priority: %ld | Reminder: %@ | File: %@",
          task.name, (long)task.priority,
          self.reminderSet ? @"YES" : @"NO",
          self.attachedFileName ?: @"NONE");
    
    NSMutableString *message = [NSMutableString stringWithFormat:
        @"\"%@\" has been added to your list.", name];
    
    if (self.reminderSet) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"MMM dd, yyyy 'at' hh:mm a";
        fmt.timeZone = [NSTimeZone localTimeZone];
        [message appendFormat:@"\n\nReminder: %@",
            [fmt stringFromDate:self.reminderDatePicker.date]];
    }

    
    UIAlertController *success = [UIAlertController
        alertControllerWithTitle:@"Task Created! ✓"
        message:message
        preferredStyle:UIAlertControllerStyleAlert];
    
    [success addAction:[UIAlertAction actionWithTitle:@"OK"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:success animated:YES completion:nil];
}


- (void)cancelTapped {
    
    BOOL hasTitle    = (self.titleTextField.text.length > 0);
    BOOL hasDesc     = (self.descriptionTextField.text.length > 0);
    BOOL hasReminder = self.reminderSet;
    BOOL hasFile     = (self.attachedFilePath != nil);
    
    if (hasTitle || hasDesc || hasReminder || hasFile) {
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:@"Discard Task?"
            message:@"You have unsaved changes. Are you sure?"
            preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Keep Editing"
            style:UIAlertActionStyleCancel handler:nil]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Discard"
            style:UIAlertActionStyleDestructive
            handler:^(UIAlertAction *action) {
                // Clean up file
                if (self.attachedFilePath) {
                    [[NSFileManager defaultManager]
                        removeItemAtPath:self.attachedFilePath error:nil];
                }
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
