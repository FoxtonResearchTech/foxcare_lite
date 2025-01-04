import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';
import '../../utilities/images.dart';
import '../../utilities/widgets/buttons/primary_button.dart';
import '../../utilities/widgets/image/custom_image.dart';
import '../../utilities/widgets/textField/primary_textField.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;
        if (constraints.maxWidth > 600) {
          // Web or large screen: horizontal split
          return Row(
            children: [
              // Left side: Login form
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(150, 0, 0, 0),
                  child: LoginForm(),
                ),
              ),
              Expanded(
                child: Center(
                  child: CustomImage(
                    path: AppImages.logo,
                    width: screenWidth * 0.25,
                    height: screenHeight * 0.35,
                  ),
                ),
              ),
            ],
          );
        } else {
          // Mobile: vertical split
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top half: Logo
              const Expanded(
                child: Center(
                  child: CustomImage(path: AppImages.logo),
                ),
              ),
              // Bottom half: Login form
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                  child: LoginForm(),
                ),
              ),
            ],
          );
        }
      },
    ));
  }
}

class LoginForm extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: 'Welcome back!',
        ),
        const CustomText(
          text: 'Enter your Credentials to access your account',
        ),
        SizedBox(height: screenHeight * 0.03),
        //Text(
        //'Email',
        //style: TextStyle(fontWeight: FontWeight.bold),
        //),
        CustomTextField(
          controller: _emailController,
          hintText: 'Enter your email',
          width: screenWidth * 0.4,
        ),
        SizedBox(height: screenHeight * 0.03),
        //Text(
        //'Password',
        //style: TextStyle(fontWeight: FontWeight.bold),
        //),
        CustomTextField(
          hintText: 'Enter Password',
          obscureText: true,
          controller: _passwordController,
          width: screenWidth * 0.4,
        ),
        SizedBox(height: screenHeight * 0.03),
        Center(
          child: CustomButton(
            label: "login",
            onPressed: () {},
            width: screenWidth * 0.1,
          ),
        )
      ],
    );
  }
}
