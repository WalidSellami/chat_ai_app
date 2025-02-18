import 'package:animate_do/animate_do.dart';
import 'package:chat_ai/shared/adaptive/loadingIndicator/LoadingIndicator.dart';
import 'package:chat_ai/shared/components/Components.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/components/Extensions.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckStates.dart';
import 'package:chat_ai/shared/cubits/forgetPassCubit/ForgotPassCubit.dart';
import 'package:chat_ai/shared/cubits/forgetPassCubit/ForgotPassStates.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {

  final TextEditingController emailController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FocusNode focusNode = FocusNode();

  bool isSend = false;


  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {

        if(isSend) {
          Future.delayed(const Duration(seconds: 1)).then((value) {
            setState(() {isSend = false;});
          });
        }

        return BlocConsumer<CheckCubit, CheckStates>(
          listener: (context, state) {},
          builder: (context, state) {

            var checkCubit = CheckCubit.get(context);

            return BlocConsumer<ForgotPassCubit, ForgotPassStates>(
              listener: (context, state) {

                if(state is SuccessForgotPassState) {

                  showFlutterToast(
                      message: 'Send with success',
                      state: ToastStates.success,
                      context: context);

                  setState(() {isSend = true;});
                }

                if(state is ErrorForgotPassState) {

                  showFlutterToast(
                      message: state.error.toString(),
                      state: ToastStates.error,
                      context: context);
                }

              },
              builder: (context, state) {

                var cubit = ForgotPassCubit.get(context);

                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                      focusNode.unfocus();
                      Navigator.pop(context);
                    }
                  },
                  child: PopScope(
                    onPopInvokedWithResult: (didPop, result) {
                      Future.delayed(const Duration(milliseconds: 500)).then((value) {
                        setState(() {isSend = false;});
                      });
                    },
                    child: Scaffold(
                      appBar: defaultAppBar(
                        onPress: () {
                          Navigator.pop(context);
                          Future.delayed(const Duration(milliseconds: 500)).then((value) {
                            setState(() {isSend = false;});
                          });
                        },
                        title: 'Reset Password',
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ConditionalBuilder(
                          condition: !isSend,
                          builder: (context) => FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  defaultFormField(
                                      label: 'Email',
                                      controller: emailController,
                                      type: TextInputType.emailAddress,
                                      focusNode: focusNode,
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
                                      },
                                      onSubmit: (value) {
                                        focusNode.unfocus();
                                        if(checkCubit.hasInternet) {
                                          if(formKey.currentState!.validate()) {
                                            cubit.restPassword(email: emailController.text);
                                          }
                                        } else {
                                          showFlutterToast(
                                              message: 'No Internet Connection',
                                              state: ToastStates.error,
                                              context: context);
                                        }
                                      }
                                  ),
                                  45.0.vrSpace,
                                  ConditionalBuilder(
                                    condition: state is! LoadingForgotPassState,
                                    builder: (context) => defaultButton(
                                        text: 'Send',
                                        onPress: () {
                                          focusNode.unfocus();
                                          if(checkCubit.hasInternet) {
                                            if(formKey.currentState!.validate()) {
                                              cubit.restPassword(email: emailController.text);
                                            }
                                          } else {
                                            showFlutterToast(
                                                message: 'No Internet Connection',
                                                state: ToastStates.error,
                                                context: context);
                                          }
                                        },
                                        context: context),
                                    fallback: (context) => LoadingIndicator(os: getOs()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          fallback: (context) => FadeInDown(
                            duration: const Duration(milliseconds: 350),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    EvaIcons.emailOutline,
                                    size: 60.0,
                                  ),
                                  30.0.vrSpace,
                                  Text(
                                    'Check Your Email',
                                    style: TextStyle(
                                      fontSize: 26.0,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                 20.0.vrSpace,
                                  Text(
                                    'We sent a reset link to your email',
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
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
    );
  }
}
