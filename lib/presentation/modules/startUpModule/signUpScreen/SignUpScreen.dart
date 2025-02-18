import 'package:animate_do/animate_do.dart';
import 'package:chat_ai/presentation/modules/startUpModule/emailVerificationScreen/EmailVerificationScreen.dart';
import 'package:chat_ai/shared/adaptive/loadingIndicator/LoadingIndicator.dart';
import 'package:chat_ai/shared/components/Components.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/components/Extensions.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckStates.dart';
import 'package:chat_ai/shared/cubits/signUpCubit/SignUpCubit.dart';
import 'package:chat_ai/shared/cubits/signUpCubit/SignUpStates.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();
  final FocusNode focusNode3 = FocusNode();

  bool isPassword = true;


  @override
  void initState() {
    passwordController.addListener(() {
      setState(() {});
    });
    super.initState();
  }


  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit, CheckStates>(
      listener: (context, state) {},
      builder: (context, state) {

        var checkCubit = CheckCubit.get(context);

        return BlocConsumer<SignUpCubit, SignUpStates>(
          listener: (context, state) {

            var cubit = SignUpCubit.get(context);

            if(state is SuccessCreateUserSignUpState) {

              showFlutterToast(
                  message: 'Sign up done successfully',
                  state: ToastStates.success,
                  context: context);

              cubit.sendEmailVerification();

              navigateAndNotReturn(context: context, screen: EmailVerificationScreen(userId: state.userModel.uId,));

            }

            if(state is ErrorCreateUserSignUpState) {

              showFlutterToast(
                  message: '${state.error}',
                  state: ToastStates.error,
                  context: context);

            }


            if(state is ErrorSignUpState) {

              showFlutterToast(
                  message: '${state.error}',
                  state: ToastStates.error,
                  context: context);

            }

          },
          builder: (context, state) {

            var cubit = SignUpCubit.get(context);

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                  focusNode1.unfocus();
                  focusNode2.unfocus();
                  focusNode3.unfocus();
                  Navigator.pop(context);
                }
              },
              child: Scaffold(
                appBar: defaultAppBar(
                  onPress: () {
                    focusNode1.unfocus();
                    focusNode2.unfocus();
                    focusNode3.unfocus();
                    Navigator.pop(context);
                  },
                ),
                body: FadeInRight(
                  duration: const Duration(milliseconds: 500),
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              ZoomIn(
                                duration: Duration(milliseconds: 500),
                                child: Image.asset('assets/images/logo.png',
                                  height: 100.0,
                                  width: 100.0,
                                ),
                              ),
                              45.0.vrSpace,
                              defaultFormField(
                                  label: 'Full Name',
                                  controller: fullNameController,
                                  type: TextInputType.name,
                                  focusNode: focusNode1,
                                  prefixIcon: Icons.person,
                                  validate: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Full Name must not be empty';
                                    }
                                    if (value.length < 4) {
                                      return 'Full Name must be at least 4 characters';
                                    }
                                    bool validName =
                                    RegExp(r'^(?=.*[a-zA-Z])[a-zA-Z0-9\s_.]+$')
                                        .hasMatch(value);
                                    if(!validName) {
                                      return 'Full Name should not contain (, - (0-9))';
                                    }
                                    return null;
                                  }),
                             30.0.vrSpace,
                              defaultFormField(
                                  label: 'Email',
                                  controller: emailController,
                                  type: TextInputType.emailAddress,
                                  focusNode: focusNode2,
                                  prefixIcon: EvaIcons.emailOutline,
                                  validate: (value) {
                                    if(value == null || value.isEmpty) {
                                      return 'Email must not be empty';
                                    }
                                    bool emailValid = RegExp(
                                        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                        .hasMatch(value);
                                    if (!emailValid) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  }
                              ),
                              30.0.vrSpace,
                              defaultFormField(
                                  label: 'Password',
                                  controller: passwordController,
                                  type: TextInputType.visiblePassword,
                                  focusNode: focusNode3,
                                  isPassword: isPassword,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffixIcon: isPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                  onPress: () {
                                    setState(() {
                                      isPassword = !isPassword;
                                    });
                                  },
                                  validate: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password must not be empty';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }
                                    bool passwordValid = RegExp(
                                        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#$&*~,.]).{8,}$')
                                        .hasMatch(value);
                                    if (!passwordValid) {
                                      return 'Enter a strong password with a mix of uppercase letters, lowercase letters, numbers, special characters(@#%&!?), and at least 8 characters';
                                    }
                                    return null;
                                  },
                                  onSubmit: (value) {
                                    focusNode1.unfocus();
                                    focusNode2.unfocus();
                                    focusNode3.unfocus();
                                    if(checkCubit.hasInternet) {
                                      if(formKey.currentState!.validate()) {
                                        cubit.userSignUp(
                                            fullName: fullNameController.text,
                                            email: emailController.text,
                                            password: passwordController.text);
                                      }
                                    } else {
                                      showFlutterToast(
                                          message: 'No Internet Connection',
                                          state: ToastStates.error,
                                          context: context);
                                    }
                                  }
                              ),
                              30.0.vrSpace,
                              ConditionalBuilder(
                                condition: state is! LoadingSignUpState,
                                builder: (context) => defaultButton(
                                    text: 'Sign Up',
                                    onPress: () {
                                      focusNode1.unfocus();
                                      focusNode2.unfocus();
                                      focusNode3.unfocus();
                                      if(checkCubit.hasInternet) {
                                        if(formKey.currentState!.validate()) {
                                          cubit.userSignUp(
                                              fullName: fullNameController.text,
                                              email: emailController.text,
                                              password: passwordController.text);
                                        }
                                      } else {
                                       showFlutterToast(
                                           message: 'No Internet Connection',
                                           state: ToastStates.error,
                                           context: context);
                                      }
                                    },
                                    context: context),
                                fallback: (context) => Center(child: LoadingIndicator(os: getOs())),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
