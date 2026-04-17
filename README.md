# Tasker - TODO List App

A feature-rich task management iOS application built with **Objective-C** and **UIKit** as part of the **ITI 9-Month Professional Training Program** — iOS track. This is our first iOS application project, demonstrating core iOS development concepts including MVC architecture, local data persistence, local notifications, file handling, and dynamic UI.

![Platform](https://img.shields.io/badge/Platform-iOS-blue)
![Language](https://img.shields.io/badge/Language-Objective--C-orange)
![Framework](https://img.shields.io/badge/Framework-UIKit-purple)
![Storage](https://img.shields.io/badge/Storage-Local_Persistence-green)
![Program](https://img.shields.io/badge/ITI-9_Month_Program-red)

---

## 🌟 Features

### ✏️ Task Creation
- Create tasks with a **name** (required), **description** (optional), and **priority level**
- Each task gets an **automatic creation date**
- Each priority level has a **unique visual icon**:
  - 🔥 **High** — Flame icon (Red)
  - ⚡ **Medium** — Bolt icon (Orange)
  - 🌿 **Low** — Leaf icon (Green)

### 📋 View Tasks
- View **all tasks** in a clean, scrollable table view
- Each cell displays the task **name**, **creation date**, and **priority icon**
- Indicators for attached files 📎 and reminders 🔔 appear on each cell

### 🔍 Task Details
- Tap any task to view its **full details**
- See the task **name**, **description**, **priority**, **status**, and **creation date**
- View the **reminder date/time** if one was set
- View the **attached file** with a smart preview:
  - **Images** → Full image preview with dynamic height
  - **PDFs** → Rendered first-page thumbnail
  - **Other files** → File type icon (Word, Excel, ZIP, etc.)
- Tap the file preview or label to **open the file** using QuickLook

### 🗑️ Delete Tasks
- **Swipe left** on any task to reveal the delete action
- Confirmation alert before permanently removing the task

### ✏️ Edit Tasks
- **Swipe right** on a task or tap **Edit** in the detail view
- Edit the task **name**, **description**, and **priority**
- Edit or remove the **attached file**
- **Confirmation required** before saving changes
- **Unsaved changes detection** — prompts before discarding edits

### 📊 Status Management
- Change task status using a segmented control in the detail view
- Enforced **one-way workflow**:
  ```
  To-Do  →  In Progress  →  Done
  ```
  - ❌ In Progress tasks **cannot** go back to To-Do
  - ❌ Done tasks **cannot** change status (permanently locked)
- Confirmation prompt before every status change

### 🔎 Search
- **Real-time search** by task name using the search bar
- Results update as you type
- **Friendly empty state** with illustration when no results are found

### 🗂️ Filter & Sort
- **Segmented control** with 5 filter options:
  - **All** — Every task
  - **To-Do** — Pending tasks only
  - **In Progress** — Active tasks only
  - **Done** — Completed tasks only
  - **Priority** — Tasks grouped into **separate sections** by priority level, each section with a colored header and icon

### 💾 Local Persistence
- All tasks and changes are **saved locally** using `NSKeyedArchiver` + `NSUserDefaults`
- Data **persists across app launches** — your tasks are always there when you come back
- File attachments stored in the app's **Documents directory**
- Smart **file path resolution** that survives iOS sandbox path changes between launches

### 🔔 Reminders (Bonus)
- Set a **date and time reminder** when creating a task
- **Local notifications** scheduled via the `UserNotifications` framework
- View the reminder date in the task detail screen
- Option to **remove the reminder** before saving

### 📎 File Attachments (Bonus)
- Attach a file when creating a task:
  - 📄 **Choose Document** — PDF, text, images, and more via Document Picker
  - 🖼️ **Choose Photo** — Select from Photo Library
- View attached files in the detail screen with **smart previews**
- **Edit or replace** the attached file while editing a task
- **Remove** the attached file at any time
- Full file viewing via **QuickLook** framework

---

## 🏗️ Project Structure

```
TODO/
├── AppDelegate.h
├── AppDelegate.m
├── SceneDelegate.h
├── SceneDelegate.m
│
├── Task.h                          # Task model — properties & NSCoding protocol
├── Task.m                          # Task init, encode/decode, file path resolution
│
├── TaskManager.h                   # Singleton manager interface
├── TaskManager.m                   # CRUD operations & local persistence (NSUserDefaults)
│
├── MainViewController.h            # Main screen interface (table view, search, filters)
├── MainViewController.m            # Task list display, filtering, search, swipe actions
│
├── AddTaskViewController.h         # Add task screen interface
├── AddTaskViewController.m         # Task creation, reminders, file attachments
│
├── TaskDetailViewController.h      # Detail/Edit screen interface
├── TaskDetailViewController.m      # View/Edit modes, file preview, status management
│
├── TaskTableViewCell.h             # Custom table view cell interface
├── TaskTableViewCell.m             # Cell configuration with priority icons
├── TaskTableViewCell.xib           # Cell layout (NIB file)
│
├── Main.storyboard                 # Storyboard layouts for all view controllers
├── LaunchScreen.storyboard         # Launch screen
│
├── Assets.xcassets/                # App icons, empty state images, colors
│   └── task_image                  # Empty state illustration
│
└── Info.plist                      # App configuration & permissions
```

---

## 🔧 Technical Details

| Component | Technology |
|-----------|-----------|
| **Language** | Objective-C |
| **UI Framework** | UIKit (Storyboard + XIB) |
| **Architecture** | MVC (Model-View-Controller) |
| **Design Pattern** | Singleton (`TaskManager`) |
| **Data Persistence** | `NSKeyedArchiver` / `NSKeyedUnarchiver` via `NSUserDefaults` |
| **Notifications** | `UserNotifications` framework (Local Notifications) |
| **File Picking** | `UIDocumentPickerViewController` + `UIImagePickerController` |
| **File Preview** | `QuickLook` framework (`QLPreviewController`) |
| **PDF Thumbnails** | `CoreGraphics` (`CGPDFDocument`) |
| **Minimum Target** | iOS 15.0+ |

---

## 📋 Implementation Highlights

### MVC Architecture
The project follows the **Model-View-Controller** pattern:
- **Model** — `Task` (data object with `NSCoding`) + `TaskManager` (singleton for CRUD & persistence)
- **View** — `Main.storyboard`, `TaskTableViewCell.xib`, custom cell class
- **Controller** — `MainViewController`, `AddTaskViewController`, `TaskDetailViewController`

### Data Persistence Strategy
- Tasks conform to `NSCoding` protocol for serialization
- Only the **filename** is archived (not the full path), so file references survive sandbox path changes when the app restarts
- The `resolvedFilePath` method dynamically reconstructs the full path at runtime

### Status Workflow Enforcement
```
┌─────────┐      ┌──────────────┐      ┌──────┐
│  To-Do  │ ───► │ In Progress  │ ───► │ Done │
└─────────┘      └──────────────┘      └──────┘
     ✅                ✅                  🔒
                   ❌ Can't go            ❌ Locked
                   back to To-Do          permanently
```

### Unsaved Changes Protection
Both the **Add Task** and **Edit Task** screens detect if the user has made changes. If they try to leave without saving, a **confirmation dialog** appears asking whether to discard or keep editing.

### Smart File Preview System
The detail screen intelligently renders file previews:
- **Images** (JPG, PNG, HEIC, etc.) → Full image with dynamic aspect ratio
- **PDFs** → First page rendered as a thumbnail using CoreGraphics
- **Documents** (DOC, TXT, XLS, ZIP, etc.) → Appropriate SF Symbol icon with matching color

---

## 🚀 Getting Started

### Prerequisites
- **macOS** with **Xcode 14+** installed
- **iOS 15.0+** simulator or physical device

### Installation & Running

1. **Clone the repository**
   ```bash
   git clone https://github.com/mahmoud-bayoumi/Tasker-iOS-TODO-Application.git
   ```

2. **Open in Xcode**
   ```bash
   cd TODO-List-App
   open TODO.xcodeproj
   ```

3. **Select a simulator** (e.g., iPhone 15) or connect a physical device

4. **Build & Run** — Press `Cmd + R`

### Permissions

| Permission | Reason |
|-----------|--------|
| **Notifications** | To schedule task reminders |
| **Photo Library** | To attach photos to tasks |

---

## 📖 How to Use

### ➕ Adding a Task
1. Tap the **+** button on the main screen
2. Enter a **task name** (required)
3. Add an optional **description**
4. Select **priority** — Low / Medium / High
5. Optionally tap **Set Reminder** and pick a date/time
6. Optionally tap **Attach File** and choose a document or photo
7. Tap **Add Task** — confirmation appears on success

### 📋 Browsing & Filtering
- Use the **segmented control** to filter: All | To-Do | In Progress | Done | Priority
- In **Priority mode**, tasks are grouped into 3 sections with colored headers
- Use the **search bar** to find tasks by name in real-time
- A friendly **empty state illustration** appears when there are no matching tasks

### 👁️ Viewing Details
- Tap any task to open its **detail screen**
- See all task information, reminder, and file preview
- Tap the **file preview** or **file label** to open the file in full-screen QuickLook viewer

### ✏️ Editing a Task
- In the detail screen, tap **Edit** in the navigation bar
- Modify the **name**, **description**, or **priority**
- Tap the **file label/preview** to change or remove the attached file
- Tap **Done** → Confirm to save changes
- Tap **Cancel** → If changes were made, a discard confirmation appears

### 🔄 Changing Status
- In the detail screen, use the **status segmented control**
- Confirm the status change when prompted
- Status rules are enforced automatically

### 🗑️ Deleting a Task
- On the main screen, **swipe left** on any task
- Tap the **Delete** button
- Confirm deletion in the alert

---

## 🎓 About

This project was developed as part of the **ITI (Information Technology Institute) 9-Month Professional Training Program — iOS Development Track**. It is our first iOS application, built to practice and demonstrate fundamental iOS development skills including:

- Objective-C programming
- UIKit and Storyboard-based UI design
- MVC architecture pattern
- Table views with custom cells (XIB)
- Local data persistence
- Local notifications
- File handling and document picking
- QuickLook file previewing
- Search and filtering
- Swipe actions and user confirmations

---

## 📄 License

This project was built for educational purposes as part of the ITI training program.

---

> Built with ❤️ using Objective-C & UIKit — ITI 9-Month Program

---

