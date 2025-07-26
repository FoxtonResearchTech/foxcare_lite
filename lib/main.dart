import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foxcare_lite/presentation/login/fetch_user.dart';
import 'package:foxcare_lite/presentation/login/login.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await UserSession.initUser();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foxcare Lite',
      home: LoginScreen(),
    );
  }
}

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Center(child: Lottie.asset('assets/login_lottie.json')),
//           );
//         }
//
//         if (!snapshot.hasData || snapshot.data == null) {
//           return LoginScreen();
//         }
//
//         final uid = snapshot.data!.uid;
//
//         return FutureBuilder<DocumentSnapshot>(
//           future:
//               FirebaseFirestore.instance.collection('employees').doc(uid).get(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Scaffold(
//                 body: Center(child: Lottie.asset('assets/login_lottie.json')),
//               );
//             }
//
//             if (!snapshot.hasData || !snapshot.data!.exists) {
//               return Scaffold(
//                 body: Center(
//                   child: Column(
//                     children: [
//                       const CustomText(text: "User document not found."),
//                       CustomButton(
//                         label: 'Logout',
//                         onPressed: () async {
//                           await FirebaseAuth.instance.signOut();
//                           UserSession.clearUser();
//
//                           Navigator.pushAndRemoveUntil(
//                             context,
//                             MaterialPageRoute(builder: (_) => LoginScreen()),
//                             (route) => false,
//                           );
//                         },
//                         width: 250,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }
//
//             final data = snapshot.data!.data() as Map<String, dynamic>;
//             final role = data['roles'];
//             final firstName = data['firstName'] ?? '';
//             final lastName = data['lastName'] ?? '';
//             final name = '$firstName $lastName'.trim();
//
//             if (UserSession.currentUser == null) {
//               UserSession.currentUser = UserModel.fromMap(data);
//             }
//
//             switch (role) {
//               case 'Management':
//                 return ManagementDashboard();
//               case 'Pharmacist':
//                 return const SalesChartScreen();
//               case 'Receptionist':
//                 return ReceptionDashboard();
//               case 'Lab Assistance':
//                 return LabDashboard();
//               case 'X-Ray Technician':
//                 return PatientRegistration();
//               case 'Doctor':
//                 return const DoctorDashboard();
//               case 'Manager':
//                 return const ManagerDashboard();
//               default:
//                 return Scaffold(
//                   body: Center(
//                     child: Text("Unknown role: $role"),
//                   ),
//                 );
//             }
//           },
//         );
//       },
//     );
//   }
// }
