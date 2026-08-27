#Requirements and User Stories

# Description
The Flutter_attend is a mobile application developed using Flutter and Firebase that simplifies attendance management in educational institutions. Users can log in with their registered SUST email addresses and are redirected to specific pages based on their roles—students or teachers.

# Main Functionality
## Authentication

Firebase Authentication handles user sign-in. The application supports both email-based authentication and Google Sign-In for eligible accounts.

## Student Portal

Students can record their presence by scanning the QR code displayed for a class. Each QR code represents a particular subject, allowing attendance to be associated with the correct course.

## Teacher Portal

Instructors can create QR codes for their subjects and use them during class sessions. They can also inspect attendance records to see which students have registered their attendance.

#Backend Database description


## Screenshots
 

Screenshots of the application interface are included below.
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

## Screenshots description

**1.Sign In Page**<br/>
If a user has an account in the attendance app, then the user can sign in through the sign
in page. For now, only SUST emails will be accepted by the sign in page. If the user does not have any
account, they can click the sign up button at the bottom and then make a user account. If a user is a
student and clicks the sign in button, the app takes the user to the student dashboard, and if the user is
a teacher, then it takes the user to the teacher dashboard.<br/>
**2.Sign up page**<br/>
If a user wants to make an account in the attendance app, they can use the sign up
page. They simply enter the SUST email address and a password, then click the sign up button and make
a user account easily. If the user is a student, then they must enter the SUST student email address, and
if the user is a teacher, then they must enter the SUST teacher's email. After clicking the sign up button,
they can easily go to their dashboard by using the sign in page.<br/>
**3.Student Dashboard**<br/>
The student dashboard consists of three segments:
first segment Displays the student's name (retrieved via their email address) and their
Registration ID, which is unique to every student.
In the middle segment it has a scanner option that allows students to scan a QR code provided by
the course teacher.
At last it’s show the Hardware ID of the device and Shows the Hardware lock and scanner
status.<br/>
**4.Teacher Dashboard**<br/>
<img width="50%" alt="teacherDashboard" src="https://github.com/user-attachments/assets/513e9d9f-979c-4871-b149-fd63af539531" />
<br/>
**5.Add subject**<br/>
<img width="%50" alt="AddSubject" src="https://github.com/user-attachments/assets/32905510-7b29-440d-aed2-a8bc052c54b2" />
<br/>
**6.Generate Qr Code**<br/>
<img width="50%"  alt="QRcode" src="https://github.com/user-attachments/assets/bb562f37-0428-4d55-924a-c8f3bf812e94" />
<br/>
**7.Qr code scanner**<br/>
 If the student clicks the scanner option, it will go to verify the QR code and
mark the student present. Each QR code is uniquely generated for a specific time frame. Students
use this scanner to record their attendance. If a student attempts to scan another QR code after
already submitting their attendance, a pop-up message will appear stating, "Already marked
present". Therefore, a student can only submit attendance once per session. Once attendance is
submitted, the teacher can view the student's Name, Registration ID, and Hardware ID.
The Hardware ID is unique to every device. If a student successfully records their attendance for
a course and then logs into another account on the same device to submit a proxy attendance for
someone else, the teacher will be able to spot the duplicate Hardware ID and flag both student
accounts.<br/>

**8.Attendance List**<br/>
<img width="50%" alt="studentList" src="https://github.com/user-attachments/assets/53e9a26d-8cd8-4f7d-9d48-19169e132599" />
<br/>
**9.Attendance confirmation**<br/>
 If the student scans the QR code successfully, it will show a page and give a message to
the student that they have successfully attended the course.<br/>

