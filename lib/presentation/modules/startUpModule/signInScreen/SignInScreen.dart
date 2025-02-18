import 'package:animate_do/animate_do.dart';
import 'package:chat_ai/presentation/modules/chatModule/ChatScreen.dart';
import 'package:chat_ai/presentation/modules/startUpModule/emailVerificationScreen/EmailVerificationScreen.dart';
import 'package:chat_ai/presentation/modules/startUpModule/forgotPassScreen/ForgotPassScreen.dart';
import 'package:chat_ai/shared/adaptive/loadingIndicator/LoadingIndicator.dart';
import 'package:chat_ai/shared/components/Components.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/components/Extensions.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckStates.dart';
import 'package:chat_ai/shared/cubits/signInCubit/SignInCubit.dart';
import 'package:chat_ai/shared/cubits/signInCubit/SignInStates.dart';
import 'package:chat_ai/shared/network/local/CacheHelper.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FocusNode focusNode1 = FocusNode();
  final FocusNode focusNode2 = FocusNode();

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

        return BlocConsumer<SignInCubit, SignInStates>(
          listener: (context, state) {

            if(state is SuccessSignInState) {

              if(state.isEmailVerified) {

                showFlutterToast(
                    message: 'Sign in done successfully',
                    state: ToastStates.success,
                    context: context);

                CacheHelper.saveCachedData(key: 'uId', value: state.userId).then((value) {

                  uId = state.userId;

                  if(context.mounted) {
                    navigateAndNotReturn(context: context, screen: const ChatScreen());
                  }

                });

              } else {

                showFlutterToast(
                    message: 'Email not verified',
                    state: ToastStates.warning,
                    context: context);

                navigateAndNotReturn(context: context, screen: EmailVerificationScreen(userId: state.userId,));

              }
            }

            if(state is ErrorSignInState) {

              showFlutterToast(
                  message: '${state.error}',
                  state: ToastStates.error,
                  context: context);
            }

          },
          builder: (context, state) {

            var cubit = SignInCubit.get(context);

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                  focusNode1.unfocus();
                  focusNode2.unfocus();
                  Navigator.pop(context);
                }
              },
              child: Scaffold(
                appBar: defaultAppBar(
                  onPress: () {
                    focusNode1.unfocus();
                    focusNode2.unfocus();
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
                                  label: 'Email',
                                  controller: emailController,
                                  type: TextInputType.emailAddress,
                                  focusNode: focusNode1,
                                  prefixIcon: EvaIcons.emailOutline,
                                  validate: (value) {
                                    if(value == null || value.isEmpty) {
                                      return 'Email must not be empty';
                                    }
                                    bool emailValid = RegExp(
                                        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                        .hasMatch(value);
                                    if (!emailValid) {
                                      return 'Enter a valid email!';
                                    }
                                    return null;
                                  }
                              ),
                              30.0.vrSpace,
                              defaultFormField(
                                  label: 'Password',
                                  controller: passwordController,
                                  type: TextInputType.visiblePassword,
                                  focusNode: focusNode2,
                                  isPassword: isPassword,
                                  prefixIcon: Icons.lock_outline_rounded,
                                  suffixIcon: isPassword ? Icons.visibility_off : Icons.visibility,
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
                                    return null;
                                  },
                                  onSubmit: (value) {
                                    focusNode1.unfocus();
                                    focusNode2.unfocus();
                                    if(checkCubit.hasInternet) {
                                      if(formKey.currentState!.validate()) {
                                        cubit.userSignIn(
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
                              Align(
                                alignment: Alignment.centerRight,
                                child: defaultTextButton(
                                  text: 'Forgot password?',
                                  onPress: () {
                                    if(checkCubit.hasInternet) {
                                      Navigator.of(context).push(createRoute(screen: const ForgotPassScreen()));
                                    } else {
                                      showFlutterToast(
                                          message: 'No Internet Connection',
                                          state: ToastStates.error,
                                          context: context);
                                    }
                                  },
                                ),
                              ),
                              30.0.vrSpace,
                              ConditionalBuilder(
                                condition: state is! LoadingSignInState,
                                builder: (context) => defaultButton(
                                    text: 'Sign In',
                                    onPress: () {
                                      focusNode1.unfocus();
                                      focusNode2.unfocus();
                                      if(checkCubit.hasInternet) {
                                        if(formKey.currentState!.validate()) {
                                          cubit.userSignIn(
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
