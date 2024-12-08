# Task Tracker

TaskTracker is a mobile application developed using the Flutter framework, designed to help users efficiently manage and track their daily tasks. With a user-friendly interface and a range of features, it simplifies task organization while providing timely notifications to keep users on track.

TaskTracker is more than just a task management tool—it is a productivity partner that helps users organize their lives, stay informed about their progress, and receive timely reminders to ensure they never miss a task.

## Features

- Splash Screen
Opens with an animated splash screen for an engaging and polished user experience.

- Main Screen (Home Screen)
The home screen is the central hub for task management, offering the following features at the top:

     . Toggle Theme: Switch between light and dark themes.

     . Delete All Tasks: Remove all tasks from the database with a single click.

     . Exit App: Close the app using an icon button.

- Task Management
Tasks are organized into two categories using TabBar and TabBarView:

     . Pending Tasks: Displays tasks yet to be completed.

     . Completed Tasks: Lists tasks marked as done.

Navigation between tabs can be done using the tabs themselves or by swiping the screen.

- Adding Tasks
Users can add new tasks by providing the following required details:

    . Title: The name of the task.

    . Description: Details about the task.

    . Start Date: The date when the task begins.

    . End Date: The date when the task should end.

Each task comes with three management options:

    . Edit Task: Slide from left to right to modify task details.
    
    . Delete Task: Slide from right to left to remove the task.
    
    . Mark as Done: For pending tasks, mark them as completed.

- Completed Tasks View
Tasks marked as completed are displayed in a separate tab.

   . In this view, users can delete tasks by sliding from right to left.

- Local Notifications

   . Task Addition Notification: A notification is displayed whenever a new task is added.

   . Morning Reminder: Notifies the user to either complete today’s tasks or add new ones if no tasks are pending.

   . Night Reminder: Reminds the user about pending tasks that need to be completed for the day.

## APP UI

![photo_1_2024-08-16_01-18-06](https://github.com/user-attachments/assets/d9287958-9391-4f60-abdf-6d26571c19c0)
![photo_2_2024-08-16_01-18-06](https://github.com/user-attachments/assets/841ab848-0287-4148-af67-5c02097f858c)
![photo_3_2024-08-16_01-18-06](https://github.com/user-attachments/assets/dd47db21-661e-4164-8b48-055074b1ec7b)
![photo_4_2024-08-16_01-18-06](https://github.com/user-attachments/assets/3743fdaf-2ab2-4836-b84e-ca478472cf37)

## Installation

To run this project locally:

Clone the repository: git clone https://github.com/ArpitAswal/TaskTracker.git

Navigate to the project directory: cd TaskTracker

Install dependencies: flutter pub get

Run the app: flutter run
    
## Tech Stack

**Flutter**: The primary framework for building the mobile application.

**Dart**: The programming language used with Flutter.

**Hive**: To store task information whether they are complete or not.

**Local Notifications**: To deliver real-time reminders and alerts.

## Usage/Examples

- Daily Task Management: Users can record and track their daily tasks, whether they are related to work, study, or personal goals.

- Study Planning: The app can be used to organize study plans, helping users focus on specific subjects or topics.

- Event Tracking: Add and track future events or goals to stay on top of important activities.

## Note

- To enable daily morning and night notifications, users must disable battery optimization for this app. This ensures the app can schedule and deliver notifications reliably.

- Scheduled notifications may occasionally be delayed due to variations in operating system performance and background task handling by different devices.

## Challenges

- One of the most challenging aspects of this project was implementing a mechanism to schedule notifications reliably at specific times (morning and night) on a daily basis.

- To achieve this, I thoroughly researched and identified the WorkManager package as a suitable solution. I conducted extensive testing and iterations to understand its functionality and fine-tune the implementation to meet the app's requirements.

- While the solution is not yet perfect, it successfully fulfills the core functionality needed for the app and provides the desired user experience. Further refinements and optimizations can be made in future iterations.

## Future Enhancements

- Task History by Calendar Month:

   . Allow users to view a history of their tasks categorized by calendar months and years.

   . Provide statistics on the number of tasks completed in each month.

- Task Alarm:

   . Enable users to set a specific time for each task, provide notifications or alarms when the set time ends, notifying users that the allocated time for the task has been completed.
  
## Contributing

Contributions are always welcome!

Please follow these steps:

1. Fork the repository.

2. Create a new branch (git checkout -b feature-branch).

3. Make your changes and commit them (git commit -m 'Add new feature').

4. Push the changes to your fork (git push origin feature-branch).

5. Create a pull request.

## Feedback

- If you have any feedback, please reach out to me at arpitaswal995@gmail.com

- If you face an issue, then open an issue in a GitHub repository.

## Design Philosophy

TaskTracker is designed to offer a seamless and practical experience for task management. Its minimalist yet powerful interface ensures that users can easily add, edit, and track their tasks, staying organized and productive throughout their day.

