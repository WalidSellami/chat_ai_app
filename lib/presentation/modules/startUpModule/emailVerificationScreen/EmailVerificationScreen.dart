import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:chat_ai/presentation/modules/chatModule/ChatScreen.dart';
import 'package:chat_ai/shared/adaptive/loadingIndicator/LoadingIndicator.dart';
import 'package:chat_ai/shared/components/Components.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/components/Extensions.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckStates.dart';
import 'package:chat_ai/shared/cubits/signUpCubit/SignUpCubit.dart';
import 'package:chat_ai/shared/cubits/signUpCubit/SignUpStates.dart';
import 'package:chat_ai/shared/network/local/CacheHelper.dart';
import 'package:chat_ai/shared/styles/Colors.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String? userId;

  const EmailVerificationScreen({super.key, required this.userId});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {

  int seconds = 180;

  int sec = 60;

  late Timer timing;

  late Timer anotherTiming;

  bool isLoading = false;

  void setTiming() {
    timing = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds > 0) {
        setState(() {seconds--;});
      } else {
        timer.cancel();
        SignUpCubit.get(context).removeAccount(userId: widget.userId!);
        showAlertVerification(context);
      }

      if (SignUpCubit.get(context).isVerified) {
        timer.cancel();
      }

      if (seconds == 60) {
        showFlutterToast(
            message: '1 minute left',
            state: ToastStates.warning,
            context: context);
      } else if (seconds == 10) {
        showFlutterToast(
            message: '10 seconds left ',
            state: ToastStates.warning,
            context: context);
      }
    });
  }

  void setSecondTiming() {
    anotherTiming = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (sec > 0) {
        setState(() {sec--;});
      } else {
        timer.cancel();
      }
      if (SignUpCubit.get(context).isVerified) {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    setTiming();
    setSecondTiming();
    super.initState();
  }

  @override
  void dispose() {
    timing.cancel();
    anotherTiming.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (CheckCubit.get(context).hasInternet) {
        SignUpCubit.get(context).autoVerified();
      }
      return BlocConsumer<CheckCubit, CheckStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var checkCubit = CheckCubit.get(context);

          return BlocConsumer<SignUpCubit, SignUpStates>(
            listener: (context, state) {
              if(state is ErrorSendEmailVerificationSignUpState) {
                showFlutterToast(
                    message: '${state.error}',
                    state: ToastStates.error,
                    context: context);
              }
            },
            builder: (context, state) {
              var cubit = SignUpCubit.get(context);

              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  showFlutterToast(
                      message: 'Verify your email!',
                      state: ToastStates.warning,
                      context: context);
                },
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text(
                      'Email Verification',
                      style: TextStyle(
                        fontSize: 19.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  body: ConditionalBuilder(
                    condition: !cubit.isVerified,
                    builder: (context) => FadeInRight(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            EvaIcons.emailOutline,
                            size: 60.0,
                          ),
                          30.0.vrSpace,
                          const Text(
                            'Check Your Email',
                            style: TextStyle(
                              fontSize: 26.0,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                         30.0.vrSpace,
                          Text.rich(
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17.0,
                              letterSpacing: 0.6,
                              height: 1.4,
                              fontWeight: FontWeight.bold,
                            ),
                            TextSpan(
                                text:
                                    'We sent a verification link to your email, verify it to continue.\n\n',
                                children: [
                                  TextSpan(
                                    text:
                                        'If you don\'t verify your email in 3 minutes, your account will be deleted.',
                                    style: TextStyle(
                                      color: redColor,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ]),
                          ),
                          30.0.vrSpace,
                          (sec > 0)
                              ? Text(
                                  '$sec',
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    color: (sec > 10)
                                        ? Theme.of(context).colorScheme.primary
                                        : redColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : ConditionalBuilder(
                                  condition: state
                                      is! LoadingSendEmailVerificationSignUpState,
                                  builder: (context) => defaultTextButton(
                                    text: 'Resend-Link',
                                    onPress: () {
                                      if (checkCubit.hasInternet) {
                                        cubit.sendEmailVerification();
                                        Future.delayed(const Duration(
                                                milliseconds: 150))
                                            .then((value) {
                                          setState(() {sec = 45;});
                                          setSecondTiming();
                                        });
                                      } else {
                                        showFlutterToast(
                                            message: 'No Internet Connection',
                                            state: ToastStates.error,
                                            context: context);
                                      }
                                    },
                                  ),
                                  fallback: (context) =>
                                      LoadingIndicator(os: getOs()),
                                ),
                        ],
                      ),
                    ),
                    fallback: (context) => FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              EvaIcons.checkmarkSquare2Outline,
                              size: 60.0,
                            ),
                            30.0.vrSpace,
                            const Text(
                              'Email Verified',
                              style: TextStyle(
                                fontSize: 26.0,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                           45.0.vrSpace,
                            ConditionalBuilder(
                              condition: !isLoading,
                              builder: (context) => defaultButton(
                                  width: 180.0,
                                  text: 'Continue',
                                  onPress: () {
                                    if (checkCubit.hasInternet) {
                                      setState(() {isLoading = true;});
                                      Future.delayed(const Duration(
                                          milliseconds: 1500))
                                          .then((value) {
                                        setState(() {isLoading = false;});
                                        if(context.mounted) {
                                          showFlutterToast(
                                              message: 'Done with success',
                                              state: ToastStates.success,
                                              context: context);
                                        }
                                        CacheHelper.saveCachedData(key: 'uId', value: widget.userId).then((value) {
                                          uId = widget.userId;
                                          cubit.updateStatus(userId: widget.userId ?? uId);
                                          if(context.mounted) {
                                            navigateAndNotReturn(
                                                context: context,
                                                screen: const ChatScreen());
                                          }
                                        });
                                      });
                                    } else {
                                      showFlutterToast(
                                          message: 'No Internet Connection',
                                          state: ToastStates.error,
                                          context: context);
                                    }
                                  },
                                  context: context),
                              fallback: (context) =>
                                  LoadingIndicator(os: getOs()),
                            ),
                          ],
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
    });
  }
}
