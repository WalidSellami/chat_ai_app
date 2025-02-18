import 'package:animate_do/animate_do.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_ai/presentation/modules/chatModule/ChatScreen.dart';
import 'package:chat_ai/presentation/modules/startUpModule/signInScreen/SignInScreen.dart';
import 'package:chat_ai/presentation/modules/startUpModule/signUpScreen/SignUpScreen.dart';
import 'package:chat_ai/shared/components/Components.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/components/Extensions.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckStates.dart';
import 'package:chat_ai/shared/cubits/signInCubit/SignInCubit.dart';
import 'package:chat_ai/shared/cubits/signInCubit/SignInStates.dart';
import 'package:chat_ai/shared/cubits/themeCubit/ThemeCubit.dart';
import 'package:chat_ai/shared/cubits/themeCubit/ThemeStates.dart';
import 'package:chat_ai/shared/network/local/CacheHelper.dart';
import 'package:chat_ai/shared/styles/Colors.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthOptionsScreen extends StatefulWidget {
  const AuthOptionsScreen({super.key});

  @override
  State<AuthOptionsScreen> createState() => _AuthOptionsScreenState();
}

class _AuthOptionsScreenState extends State<AuthOptionsScreen> {
  bool isAnimate = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit, CheckStates>(
      listener: (context, state) {},
      builder: (context, state) {

        var checkCubit = CheckCubit.get(context);

        return BlocConsumer<ThemeCubit, ThemeStates>(
          listener: (context, state) {},
          builder: (context, state) {
            var themeCubit = ThemeCubit.get(context);

            return BlocConsumer<SignInCubit, SignInStates>(
              listener: (context, state) {

                if (state is SuccessCreateAccountGoogleSignInState) {
                  showFlutterToast(
                      message: 'Sign in done successfully',
                      state: ToastStates.success,
                      context: context);

                  CacheHelper.saveCachedData(key: 'uId', value: state.userModel.uId)
                      .then((value) {
                    uId = state.userModel.uId;

                    if(context.mounted) {
                      Navigator.pop(context);
                      navigateAndNotReturn(
                          context: context, screen: const ChatScreen());
                    }

                    setState(() {isAnimate = true;});
                  });
                }

                if (state is SuccessGoogleSignInState) {
                  showFlutterToast(
                      message: 'Sign in done successfully',
                      state: ToastStates.success,
                      context: context);

                  CacheHelper.saveCachedData(key: 'uId', value: state.userId)
                      .then((value) {
                    uId = state.userId;

                    if(context.mounted) {
                      Navigator.pop(context);
                      navigateAndNotReturn(
                          context: context, screen: const ChatScreen());
                    }

                    setState(() {isAnimate = true;});
                  });
                }

                if (state is ErrorGoogleSignInState) {
                  showFlutterToast(
                      message: '${state.error}',
                      state: ToastStates.error,
                      context: context);

                  Navigator.pop(context);

                  setState(() {isAnimate = true;});
                }

                if (state is ErrorCreateAccountGoogleSignInState) {
                  showFlutterToast(
                      message: '${state.error}',
                      state: ToastStates.error,
                      context: context);

                  Navigator.pop(context);

                  setState(() {
                    isAnimate = true;
                  });
                }
              },
              builder: (context, state) {
                var cubit = SignInCubit.get(context);

                return PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    showAlertExit(context);
                  },
                  child: Scaffold(
                    appBar: AppBar(
                      systemOverlayStyle: SystemUiOverlayStyle(
                        statusBarColor: Theme.of(context).scaffoldBackgroundColor,
                        statusBarIconBrightness: themeCubit.isDarkTheme
                            ? Brightness.light : Brightness.dark,
                        systemNavigationBarColor: themeCubit.isDarkTheme
                            ? firstColor : secondColor,
                        systemNavigationBarIconBrightness: themeCubit.isDarkTheme
                            ? Brightness.light : Brightness.dark,
                      ),
                    ),
                    body: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: AvatarGlow(
                              startDelay: const Duration(milliseconds: 1000),
                              duration: const Duration(milliseconds: 2000),
                              glowColor: themeCubit.isDarkTheme
                                  ? Colors.blueGrey.shade800
                                  : Colors.lightBlue.shade100,
                              glowShape: BoxShape.circle,
                              animate: isAnimate,
                              curve: Curves.fastOutSlowIn,
                              glowCount: 2,
                              repeat: true,
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 150.0,
                                width: 150.0,
                              ),
                            ),
                          ),
                        ),
                        FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          child: Material(
                            clipBehavior: Clip.antiAlias,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24.0),
                              topRight: Radius.circular(24.0),
                            ),
                            color: themeCubit.isDarkTheme
                                ? firstColor
                                : secondColor,
                            child: Padding(
                              padding: const EdgeInsets.all(26.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      if(checkCubit.hasInternet) {
                                        setState(() {isAnimate = false;});
                                        showLoading(context);
                                        cubit.signInWithGoogle(context);
                                      } else {
                                        showFlutterToast(
                                            message: 'No Internet Connection',
                                            state: ToastStates.error,
                                            context: context);
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(EvaIcons.google),
                                        8.0.hrSpace,
                                        Text(
                                          'Sign in with google',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  20.0.vrSpace,
                                  OutlinedButton(
                                    onPressed: () {
                                      if(checkCubit.hasInternet) {
                                        Navigator.of(context).push(createSecondRoute(screen: const SignInScreen()));
                                      } else {
                                        showFlutterToast(
                                            message: 'No Internet Connection',
                                            state: ToastStates.error,
                                            context: context);
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(EvaIcons.emailOutline),
                                        8.0.hrSpace,
                                        Text(
                                          'Sign in with email',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  20.0.vrSpace,
                                  OutlinedButton(
                                    onPressed: () {
                                      if(checkCubit.hasInternet) {
                                        Navigator.of(context).push(createSecondRoute(screen: const SignUpScreen()));
                                      } else {
                                        showFlutterToast(
                                            message: 'No Internet Connection',
                                            state: ToastStates.error,
                                            context: context);
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(EvaIcons.emailOutline),
                                        8.0.hrSpace,
                                        Text(
                                          'Sign up with email',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
