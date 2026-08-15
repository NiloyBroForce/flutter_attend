# Description
The Flutter_attend is a mobile application developed using Flutter and Firebase that simplifies attendance management in educational institutions. Users can log in with their registered SUST email addresses through google sign in or personal email and are redirected to specific pages based on their roles—students or teachers.

# Main Functionality
## Authentication

Firebase Authentication handles user sign-in. The application supports both email-based authentication and Google Sign-In for eligible accounts.

## Student Portal

Students can record their presence by scanning the QR code displayed for a class. Each QR code represents a particular subject, allowing attendance to be associated with the correct course.

## Teacher Portal

Instructors can create QR codes for their subjects and use them during class sessions. They can also inspect attendance records to see which students have registered their attendance.

Role-Specific Interfaces

The application separates student and teacher functionality so that each type of user only receives the tools relevant to their role.

## Screenshots
 

Screenshots of the application interface and its primary workflows are included below.
<p align="center">
  <img src="https://github.com/user-attachments/assets/f19bc649-e286-4e35-9ab1-68e5dad4ef67" alt="SignIn" height="400" />
  <img src="https://github.com/user-attachments/assets/771f9516-62a2-4699-af97-343e6b2d7dc4" alt="SignUp" height="400" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/4a6f9d01-785f-4c26-a835-d8925167fa52" alt="StudentDashboard2" height="400" />
  <img src="https://github.com/user-attachments/assets/006ab0e7-ea54-4c7b-a54f-f33f40fe1e4e" alt="StudentDashboard" height="400" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/de650c7f-5538-4d91-a18b-2809782e17ac" alt="TeacherDashboard" height="400" />
  <img src="https://github.com/user-attachments/assets/08811d25-684b-489f-abb0-557ef71cc395" alt="AddSubjectForm" height="400" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/9f4bfbd2-bf11-4945-9d01-e17923d940db" alt="QrCode" height="400" />
  <img src="https://github.com/user-attachments/assets/d3d64455-05d5-41b9-9626-d7c7030c2f64" alt="ScanQrCode" height="400" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/fb3a94f9-6d9c-40aa-9fed-7e1820bfc926" alt="AttendanceList" height="400" />
  <img src="https://github.com/user-attachments/assets/a9c16403-4656-4f33-8190-09eb12070156" alt="AttendanceConfirmation" height="400" />
</p>



# Getting Started
## Requirements

Before setting up the project, install:

Flutter SDK
A Firebase project
A configured Android development environment or compatible Flutter target
1. Get the Source Code

Clone the repository:

git clone https://github.com/NiloyBroForce/flutter_attend.git
cd flutter_attend
2. Install Flutter Packages

Fetch the project's dependencies:

flutter pub get
3. Configure Firebase

Create a project through the Firebase Console and configure it for the application.

## Authentication

Open Firebase Console → Authentication → Sign-in method and enable the authentication providers required by the application, including:

Email/Password
Google Sign-In
Cloud Firestore

Set up Cloud Firestore: In Firebase Console, go to Firestore Database, and create a new Firestore database. Start in "Test Mode" for development, but ensure you configure security rules later for production.

## Android Configuration

Register the Android application with your Firebase project and obtain its Firebase configuration file.

Place:

google-services.json

inside:

android/app/
4. Verify Firebase Dependencies

The Flutter project should include the Firebase and QR-scanning packages required by the application, such as:

dependencies:
  firebase_core: latest_version
  firebase_auth: latest_version
  cloud_firestore: latest_version
  qr_code_scanner: latest_version

After making dependency changes, run:

flutter pub get
5. Launch the Application

Connect an Android device or start an emulator and execute:

flutter run

Make sure the Firebase configuration corresponds to the application before launching it.

# Using the Application
## Students
Sign in using an authorized account.
Open the attendance functionality.
Scan the QR code provided for the class.
The attendance record is submitted for the corresponding subject.
## Teachers
Sign in using a teacher account.
Select the relevant subject.
Generate the QR code for students to scan.
Review the attendance records to see which students have registered.
