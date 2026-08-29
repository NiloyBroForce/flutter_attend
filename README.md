# Attendance android app Requirements
1. The system should run on 32 bit and 64 bit ARM android phones.
2. The system must provide sign up and sign in functionality
3. The system must provide helpful error messages that instruct the user on what to do.
4. The system shall have good color contrast for various phone resolutions.
5. The system must provide a student dashboard where students can submit their attendance.
6. The system must provide a teacher dashboard where a teacher can track attendance of registered students.

# User Stories
1. As a Teacher, I want an easy to use responsive interface. I want to log in using my institution email so that I can access my assigned courses. I want to be able to easily view attendance list of students.
2. As a student, I want information of courses to be easily accessible from the interface. I want easy log in feature that links with my registration id. I want to quickly mark my attendance for my registered courses.

# Description
The Flutter_attend is a mobile application developed using Flutter and Firebase that simplifies attendance management in educational institutions. Users can log in with their registered SUST email addresses and are redirected to specific pages based on their roles—students or teachers.

# Main Functionality
## Authentication

Firebase Authentication handles user sign-in. The application supports both email-based authentication for eligible accounts.

## Student Portal

Students can record their presence by submitting the otp code displayed for a class. Each otp code represents a particular subject, allowing attendance to be associated with the correct course.

## Teacher Portal

Instructors can create otp codes for their subjects and use them during class sessions. They can also inspect attendance records to see which students have registered their attendance.

# Backend Database description
<img height="500" alt="Diagram" src="https://github.com/user-attachments/assets/26a5d441-7a12-4bd4-b4a3-1b774050149c" />
<br>
The database used is Firebase, which is a no-sql database that organises data into documents and collections. The data is saved as key-value pairs. The subject collection contains string activeOtp which is what the student tries to match to mark attendance. For each student, a session sub-collection is generated that contains student information. A subject collection can have one-to-many session subcollections.

## Screenshots
 
Screenshots of the application interface are included below.
<p align="center">
  <img src="https://github.com/user-attachments/assets/ad04fe1e-f0db-48d8-a004-57f85dd3de25" alt="Login" height="400"/>
  <img src="https://github.com/user-attachments/assets/d093888f-5b0c-49ce-bf50-ac77ab842419" alt="StudentDashboard" height="400" />
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/1c34382e-0cc5-4d80-8ed3-909629db1d9b" alt="TeacherDashboard" height="400" />
  <img src="https://github.com/user-attachments/assets/c2bef120-e4f8-447d-a659-1c76fb9abe59" alt="AddSubjectForm" height="400" />

</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/294233c7-f0ef-4ac9-b5da-2fea03133774" alt="Code" height="400" />
  <img src="https://github.com/user-attachments/assets/988916c5-baea-4199-a058-62234b2d76f9"  alt="AttendanceList" height="400" />
</p>

## Screenshots description

**1.Login Page**<br/>
If a user has an account in the attendance app, then the user can sign in through the sign
in page. For now, only SUST emails will be accepted by the sign in page. If the user does not have any
account, they can click the sign up button at the bottom and then make a user account. If a user is a
student and clicks the sign in button, the app takes the user to the student dashboard, and if the user is
a teacher, then it takes the user to the teacher dashboard.<br/>
<br/>
**2.Student Dashboard**<br/>
The student can submit a otp code to mark their attendance in the student dashboard.
On success a snackbar will show that says Attendance marked successfully!
On failure it will say invalid code.
<br/>

**3.Teacher Dashboard**<br/>
The teacher can add courses using the floating action button. The teacher can generate otp code for each subject by choosing generate code option. This creates a new session for marking attendance. The otp code expires every 6 seconds in a single session. Invalid otp codes are not accepted. The teacher can also click the subject card to see a list of student attendance.
<br/>

**4.Add subject**<br/>
The add subject dialog box lets the teacher add a subject course. This writes it into firebase and updates the teacher dashboard UI in real time to show the new subject.
<br/>

**5.Generate Code**<br/>
The page shows an random otp code that re-generates every 6 seconds. This is what a student inputs on their side. Entering expired otp code is rejected, which prevents proxy attendance.
<br/>

**6.Attendance List**<br/>
This page shows a list of students that have successfully marked their attendance for that course.
<br/>




