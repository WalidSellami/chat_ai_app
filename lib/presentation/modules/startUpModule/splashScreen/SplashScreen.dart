import 'package:animate_do/animate_do.dart';
import 'package:chat_ai/shared/adaptive/loadingIndicator/LoadingIndicatorKit.dart';
import 'package:chat_ai/shared/components/Components.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/components/Extensions.dart';
import 'package:chat_ai/shared/cubits/appCubit/AppCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckStates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {

  final Widget startWidget;

  const SplashScreen({super.key,required this.startWidget});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool isDisconnected = false;
  bool isChecking = false;
  bool isShowed = false;

  @override
  void initState() {
    super.initState();

    final startTime = DateTime.now();

    Future.delayed(const Duration(seconds: 1)).then((value) {

      if(!mounted) return;
      if(CheckCubit.get(context).hasInternet == true) {

        if(uId != null) AppCubit.get(context).getProfile();
        Future.delayed(const Duration(milliseconds: 800)).then((value) {

          if(!mounted) return;
          navigateAndNotReturn(context: context, screen: widget.startWidget);
          CheckCubit.get(context).changeStatus();

          if(isChecking) {
            setState(() {
              isChecking = false;
            });
          }
        });

      } else {

        Future.delayed(const Duration(milliseconds: 1500)).then((value) {
          if(!isDisconnected) {
            setState(() {isChecking = true;});

            Future.delayed(const Duration(seconds: 5)).then((value) {
              if(isChecking) {
                final elapsedTime = DateTime.now().difference(startTime).inSeconds;

                if (elapsedTime > 5) {
                  setState(() {
                    isChecking = false;
                    isShowed = true;
                  });
                  if(!mounted) return;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showAlertCheckConnection(context, isSplashScreen: true);
                  });
                }
              }
            });
          }
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit, CheckStates>(
      listener: (context, state) {

        var checkCubit = CheckCubit.get(context);

        if(state is SuccessCheckState) {
          if(!checkCubit.hasInternet) {
            Future.delayed(const Duration(milliseconds: 800)).then((value) {
              setState(() {isDisconnected = true;});
              if(isChecking) setState(() {isChecking = false;});
              if(context.mounted) {
                if(!isShowed) showAlertCheckConnection(context, isSplashScreen: true);
              }
            });
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              Expanded(
                child: ZoomIn(
                  duration: const Duration(milliseconds: 700),
                  child: Center(
                    child: Image.asset('assets/images/logo.png',
                      height: 170.0,
                      width: 170.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                  duration: Duration(milliseconds: 700),
                  clipBehavior: Clip.antiAlias,
                  curve: Curves.easeInOut,
                  child: Column(
                    children: [
                      if(isChecking) ...[
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: const Text(
                            'Checking for connection ...',
                            style: TextStyle(
                              fontSize: 15.0,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                       20.0.vrSpace,
                        FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            child: LoadingIndicatorKit(os: getOs())),
                        const SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ],
                  ),
              ),
            ],
          ),
        );
      },
    );
  }
}
