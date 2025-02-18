import 'package:chat_ai/shared/cubits/checkCubit/CheckStates.dart';
import 'package:chat_ai/shared/styles/Colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:overlay_support/overlay_support.dart';

class CheckCubit extends Cubit<CheckStates> {

  CheckCubit() : super(InitialCheckState());

  static CheckCubit get(context) => BlocProvider.of(context);


  bool hasInternet = true;

  bool isSplashScreen = true;


  void checkConnection() {

    InternetConnection().onStatusChange.listen((event) {

      final bool isConnected = (event == InternetStatus.connected);
      hasInternet = isConnected;

      (!isSplashScreen) ? showSimpleNotification(
        (hasInternet) ? const Text(
          'You are connected with internet',
          style: TextStyle(
            fontSize: 17.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ) : const Text(
          'You are not connected with internet',
          style: TextStyle(
            fontSize: 17.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: (hasInternet) ? greenColor : Colors.red,
      ) : null;

      if(kDebugMode) {
        print(hasInternet);
      }

      emit(SuccessCheckState());

    });
  }


  void changeStatus() {
    isSplashScreen = false;
    emit(ChangeStatusCheckState());
  }

}