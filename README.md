# MSUFCU Project Title

Digital Transformation of Member Data

# Project Description

Established in 1937, MSU Federal Credit Union (MSUFCU) has been serving Michigan State University and the greater Lansing area for over 84 years. With over 20 branch locations statewide, 331,000 members, and managing nearly $7 billion in assets, MSUFCU strives to help its local communities thrive and achieve financial freedom.

To encourage community engagement and outreach, MSUFCU partners with local businesses by offering discounts and rewards to MSUFCU members through a program known as Local Loyalty.

The benefits are mutual for both members and businesses; MSUFCU members have access to rewards and discounts – keeping their MSUFCU cards top-of-wallet, while local businesses gain free exposure and generate more business.

Our Digital Transformation of Member Data mobile application enhances these benefits by increasing awareness of the Local Loyalty program and providing members with a more robust member-to-member fund transfer experience.

Our application analyzes a user’s transaction history and suggests partner companies that provide similar services to businesses where members are already shopping.

For example, if a member goes to an out-of-network coffee shop regularly, our application sends a notification suggesting a locally-partnered coffee shop offering a similar service at a discount if they use their MSUFCU card.

MSUFCU members can also use our improved fund transfer system, which now includes usernames, QR code scanning for physical device readers, and NFC tap-to-pay functionality.

Our application is available on Android and iOS devices. It is built on the Flutter SDK, using the Dart programming language to deploy on both platforms. It connects to a remotely hosted MySQL server whose data is analyzed with Python.

---

The current MSUFCU banking app has push notifications for things like fraud alert and other security risks, which have been effective at alerting members. We expanded this functionality to produce recommendations of relevant Local Loyalty businesses to members. This way, members would be more likely to see the savings they are missing and begin shopping with MSUFCU partner companies. To allow users to view their recommendations at their own leisure, we added the ability to view all Local Loyalty offers and their recommendation status. This menu lists Local Loyalty partners relevant to a specific member and can be sorted by region, name, and relevance. This will allow members to review potential savings if they miss or choose not to receive push notifications.

There are several limitations to the current MSUFCU money transfer system, Member2Member (M2M), compared to other platforms like Venmo and Cash App. M2M can only be used amongst other members of MSUFCU, and there are a lack of QR codes, username handles, and contactless payment capabilities. Adding these features helps the MSUFCU M2M feature be more competitive with other money management applications.

Currently, individuals must enter the phone number or e-mail address of the person they would like to transfer money to. The phone number and e-mail information are saved into a contact within the app once a member sends money, but the receiver must seek out the sender’s information if they wish to send money back. The following application contains username handles, alongside contactless payment features like QR code scanning, NFC tap-to-pay, and Bluetooth, all of which will help members transfer money easily.

## Installation and Running the Project

This project is built using the flutter framework, so the first step will be to install flutter. 

Flutter installation guide:
https://docs.flutter.dev/get-started/install

This covers the installation for the different OS and will also give instructions on how to install the necessary simulators needed to run this project.

Our team reccomends using Microsoft's Visual Studio Code application to run the application. This can be downloaded from:
https://code.visualstudio.com/.

Once launched, navigate to the extensions button (or hit Ctrl+Shift+X), and download both the Dart and Flutter extensions. These will provide both syntax highlighting and predefined runtime features that will aid in smooth execution of our application. These can be found below:
>Name: Dart<br>
>Id: Dart-Code.dart-code<br>
>Description: Dart language support and debugger for Visual Studio Code.<br>
>Version: 3.54.1<br>
>Publisher: Dart Code<br>
>VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code

>Name: Flutter<br>
>Id: Dart-Code.flutter<br>
>Description: Flutter support and debugger for Visual Studio Code.<br>
>Version: 3.54.0<br>
>Publisher: Dart Code<br>
>VS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter

Once Flutter, Dart, and VSCode have all been installed, open the project source folder in VSCode. 

The next step is to fetch all the packages that are imported and used in the code of this project.

If using VSCode, the applicaiton may automatically run flutter pub get and retrieve all the packages necessary, if not run the following command in the root project directory: 

`flutter pub get`

Finally, with all packages loaded, by navigating to the Run & Debug button (Ctrl+Shift+D), with the project open, you should see the option to Click the green run button with a run configuration named "Flutter". Select a device to emulate, as specified in the flutter installation, and Flutter will begin to load the project.

With the current database that is being used on MSU servers, the only way to connect is to use a device connected to the MSU VPN, or a device connected to the MSU WiFi network. However, if a different database is specified in `msufcu-flutter-project\lib\sql\connection.dart`, inside the openConnection() function, then theoretically a connection could be opened from anywhere, assuming that the MySQL server was created and shared properly.

# Credits
<b>Team MSUFCU <br>
(Michigan State University Fall Semester 2023):</b><br><br>
Vishnu Bhupathiraju<br>
Sadeem Boji<br>
Chris Cardimen<br>
Chris Chen<br>
Liam McCune<br>
Jotham Teshome<br>

<b>Instructional Staff:</b><br>

Wayne Dyksen (Instructor)<br>
James Mariani (Instructor)<br>
Luke Sperling (Graduate Teaching Assistant)<br>
Tommy Hojnicki (Graduate Teaching Assistant)<br>
Griffin Klevering (Graduate Teaching Assistant)<br>

<b>Project Sponsor:</b><br>
Michigan State University Federal Credit Union
