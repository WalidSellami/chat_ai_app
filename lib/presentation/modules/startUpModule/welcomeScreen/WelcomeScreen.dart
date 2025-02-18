import 'package:animate_do/animate_do.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_ai/presentation/modules/startUpModule/authOptionsScreen/AuthOptionsScreen.dart';
import 'package:chat_ai/shared/components/Components.dart';
import 'package:chat_ai/shared/components/Extensions.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckStates.dart';
import 'package:chat_ai/shared/network/local/CacheHelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit, CheckStates>(
      listener: (context, state) {},
      builder: (context, state) {

        var checkCubit = CheckCubit.get(context);

        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ZoomIn(
                  child: Image.asset('assets/images/hello.png',
                    height: 120.0,
                    width: 120.0,
                  ),
                ),
                FadeInRight(
                  child: Column(
                    children: [
                      Text.rich(
                        TextSpan(
                          text: 'Welcome To ',
                          children: [
                            TextSpan(
                              text: 'ChatAI',
                              style: TextStyle(
                                fontSize: 26.0,
                                letterSpacing: 0.6,
                                color: HexColor('0c77fa'),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          style: const TextStyle(
                            fontSize: 24.0,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                     26.0.vrSpace,
                      const Text(
                        'Your intelligent conversational assistant',
                        style: TextStyle(
                          fontSize: 16.0,
                          // fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                      12.0.vrSpace,
                      Text.rich(
                        TextSpan(
                          text: 'Based on ',
                          children: [
                            TextSpan(
                              text: 'Google Gemini Model',
                              style: TextStyle(
                                color: HexColor('0c77fa'),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          style: const TextStyle(
                            fontSize: 16.0,
                            // fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
               30.0.vrSpace,
                FadeInUp(
                  child: AvatarGlow(
                    startDelay: const Duration(milliseconds: 650),
                    duration: const Duration(milliseconds: 1300),
                    glowColor: Theme.of(context).colorScheme.primary,
                    glowShape: BoxShape.circle,
                    animate: true,
                    curve: Curves.fastOutSlowIn,
                    glowCount: 2,
                    repeat: true,
                    child: SizedBox(
                      width: 80.0,
                      height: 80.0,
                      child: FloatingActionButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        elevation: 10.0,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        enableFeedback: true,
                        onPressed: () async {
                          if(checkCubit.hasInternet) {
                            await getStarted(context);
                          } else {
                            showFlutterToast(
                                message: 'No Internet Connection',
                                state: ToastStates.error,
                                context: context);
                          }
                        },
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 28.0,
                        ),
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
  }

  Future<void> getStarted(context) async {
    await CacheHelper.saveCachedData(key: 'isStarted', value: true).then((value) {
      if(value == true) {
        navigateAndNotReturn(context: context, screen: const AuthOptionsScreen());
      }
    });
  }
}
