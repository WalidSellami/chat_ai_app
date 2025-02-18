import 'dart:convert';
import 'dart:io';
import 'package:chat_ai/data/models/userModel/UserModel.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/cubits/appCubit/AppStates.dart';
import 'package:chat_ai/shared/network/remot/DioHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AppCubit extends Cubit<AppStates> {

  AppCubit() : super(InitialAppState());

  static AppCubit get(context) => BlocProvider.of(context);


  UserModel? userModel;
  
  void getProfile() async {

    emit(LoadingGetProfileAppState());

    await FirebaseFirestore.instance.collection('users').doc(uId).get().then((value) {

      if(value.data()!['uId'] == uId) {
        userModel = UserModel.fromJson(value.data()!);
      }


      emit(SuccessGetProfileAppState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in get profile data');
      }

      emit(ErrorGetProfileAppState(error));

    });

  }


  void signOut() {

    FirebaseAuth.instance.signOut().then((value) {

      emit(SuccessSignOutAppState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in sign out');
      }

      emit(ErrorSignOutAppState(error));

    });

  }


  int? globalIndex;
  int? currentIndex;
  int? selectCurrentIndex;

  
  void changeIndexing({
    required int gIndex,
    required int innerIndex,
}) {
    globalIndex = gIndex;
    currentIndex = innerIndex;
    emit(SuccessChangeIndexingAppState());
  }

  // When chat is removed
  void selectAndChangeIndexing({
    required int gIndex,
    required int innerIndex,
    bool canChange = false,
  }) {
    if(globalIndex == gIndex) {
      if(!canChange) {
        selectCurrentIndex = innerIndex;
      } else {
        currentIndex = innerIndex;
      }
    }
    emit(SuccessSelectAndChangeIndexingAppState());
  }
  
  void clearIndexing() {
    globalIndex = null;
    currentIndex = null;
    emit(SuccessClearAppState());
  }

  void clearSearchChatId({
    required String? idSearchChat,
}) {
    if(idSearchChat != null) idSearchChat = null;
    emit(SuccessClearAppState());
  }

  
  List<String> idChats = [];
  List<dynamic> chats = [];

  List<dynamic> messages = [];

  String idChatCreated = '';

  Future<void> sendMessage({
    required String message,
    required dynamic dateTime,
    required dynamic timesTamp,
    String? idChat,
}) async {

    emit(LoadingSendMessageAppState());

    if(messages.isEmpty) {

      await FirebaseFirestore.instance.collection('users').doc(uId).collection('chats').
      where('name_lowercase', isEqualTo: message.toLowerCase()).get().then((value) async {

        if(value.docs.isEmpty) {

          await addChat(message: message, dateTime: dateTime, timesTamp: timesTamp);

        } else {

          await addChat(name: '$message - (same)', message: message, dateTime: dateTime, timesTamp: timesTamp);

        }

      }).catchError((error) {

        if(kDebugMode) {
          print('${error.toString()} --> in search for (same) chat');
        }

        emit(ErrorSendMessageAppState(error));

      });

    } else {

      if(imageUpload == null) {

        await addUserMessage(idChat: idChat ?? idChatCreated, message: message, timesTamp: timesTamp).then((v) {
          getMessages(idChat: idChat ?? idChatCreated);
        });

        await postMessage(message: message, idChat: idChat ?? idChatCreated);

      } else {

        uploadAndGetImageUrl(idChat: idChat ?? idChatCreated, message: message, timesTamp: timesTamp);

      }

    }

  }


  Future<void> addChat({
    String? name,
    required String message,
    required dynamic dateTime,
    required dynamic timesTamp,
}) async {

    await FirebaseFirestore.instance.collection('users').doc(uId).collection('chats').add({
      'name': name ?? message,
      'name_lowercase': name?.toLowerCase() ?? message.toLowerCase(),
      'date_time': dateTime,
      'times_tamp': timesTamp,
    }).then((value) async {

      idChatCreated = value.id;
      globalIndex = 0;
      currentIndex = 0;

      getChats();

      if(imageUpload == null) {

        await addUserMessage(idChat: value.id, message: message, timesTamp: timesTamp).then((v) {
          getMessages(idChat: value.id);
        });

        await postMessage(message: message, idChat: value.id);

      } else {

        uploadAndGetImageUrl(idChat: value.id, message: message, timesTamp: timesTamp);

      }

    }).catchError((error) {

      if (kDebugMode) {
        print('${error.toString()} --> in add chat');
      }

      emit(ErrorAddChatAppState(error));

    });

  }


  Map<String, List<String>> groupedIdChats = {};
  Map<String, List<dynamic>> groupedChats = {};

  void getChats() {

    emit(LoadingGetChatsAppState());

    FirebaseFirestore.instance.collection('users').doc(uId).collection('chats')
        .orderBy('times_tamp', descending: true).get().then((value) {

      idChats = [];
      chats = [];

      groupedIdChats = {};
      groupedChats = {};

      for(var element in value.docs) {
        idChats.add(element.id);
        chats.add(element.data());
      }

      looping(dataChats: chats, idDataChats: idChats,
          groupChats: groupedChats, groupIdChats: groupedIdChats);

      emit(SuccessGetChatsAppState());

    });

  }


  void looping({
    required List<dynamic> dataChats,
    required List<String> idDataChats,
    required Map<String, List<dynamic>> groupChats,
    required Map<String, List<String>> groupIdChats,
}) {
    if (dataChats.isNotEmpty && idDataChats.isNotEmpty) {
      for (int i = 0; i < dataChats.length; i++) {
        var chat = dataChats[i];
        var id = idDataChats[i];

        String status = categorizeDate(chat['date_time']);

        groupChats.putIfAbsent(status, () => []);
        groupChats[status]?.add(chat);

        groupIdChats.putIfAbsent(status, () => []);
        groupIdChats[status]?.add(id);
      }
    }
    emit(SuccessLoopingAppState());
  }



  String categorizeDate(date) {
    DateTime chatDate = DateTime.parse(date);
    DateTime now = DateTime.now();
    Duration difference = now.difference(chatDate);

    if (difference.inDays >= 365) {
      return 'Previous year';
    } else {
      for (int i = 11; i >= 1; i--) {
        if (difference.inDays >= i * 30) {
          if (i == 1) {
            return 'Previous 30 days';
          } else {
            return 'Previous $i months';
          }
        }
      }
      if (difference.inDays >= 15) {
        return 'Previous 15 days';
      } else if (difference.inDays >= 7) {
        return 'Previous 7 days';
      } else if (difference.inDays >= 3) {
        return 'Previous 3 days';
      } else if (difference.inDays >= 1) {
        return 'Yesterday';
      } else {
        return 'Today';
      }
    }
  }



  List<String> idSearchChats = [];
  List<dynamic> searchChats = [];

  void searchChat({
    required String chatName,
}) {

    FirebaseFirestore.instance.collection('users').doc(uId).collection('chats')
        .where('name_lowercase',
        isGreaterThanOrEqualTo: chatName.toLowerCase(),
        isLessThan: '${chatName.toLowerCase()}z').get().then((value) {

          idSearchChats = [];
          searchChats = [];

          groupedIdChats = {};
          groupedChats = {};

          for(var element in value.docs) {
            idSearchChats.add(element.id);
            searchChats.add(element.data());
          }

          looping(dataChats: searchChats, idDataChats: idSearchChats,
              groupChats: groupedChats, groupIdChats: groupedIdChats);

          emit(SuccessSearchChatAppState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in search chat');
      }

      emit(ErrorSearchChatAppState(error));

    });


  }

  Future<void> addUserMessage({
    required String idChat,
    required String message,
    required dynamic timesTamp,
    String? imageUrl,
}) async {

    await FirebaseFirestore.instance.collection('users').doc(uId).collection('chats').
    doc(idChat).collection('messages').add({
      'message': message,
      'is_user': true,
      'image_url': imageUrl ?? '',
      'times_tamp': timesTamp,
    }).then((value) {

      emit(SuccessAddUserMessageAppState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in add user message');
      }

      emit(ErrorAddUserMessageAppState(error));
    });


  }


  Future<void> addAiMessage({
    required String idChat,
    required String message,
    required dynamic timesTamp,
  }) async {

    await FirebaseFirestore.instance.collection('users').doc(uId).collection('chats').
    doc(idChat).collection('messages').add({
      'message': message,
      'is_user': false,
      'times_tamp': timesTamp,
    }).then((value) {

      emit(SuccessAddAiMessageAppState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in add ai message');
      }

      emit(ErrorAddAiMessageAppState(error));
    });

  }


  List<String> idMessages = [];
  List<dynamic> selectChatMessages = [];

  List<dynamic> historyMessages = [];

  void generateHistOfMsgs({
    required String role,
    required String text,
    bool isImageUploaded = false,
    String? extension,
    String? imgBase64,
}) {

    if(!isImageUploaded) {

      historyMessages.add({
        'role': role,
        'parts': [{'text': text}],
      });

    } else {

        historyMessages.add({
          'role': role,
          'parts': [{'text': text},
            {'inlineData': {
              'mimeType': 'image/$extension',
              'data': imgBase64,}}],
        });
    }

   emit(SuccessGenerateHistoryMessagesAppState());

  }


  Future<void> generateHistOfImgMsg({
    required String role,
    required String imageUrl,
    required String text,
}) async {

    emit(LoadingGetMessagesAppState());

    Uri uri = Uri.parse(imageUrl);
    String typeImage = uri.path.split('.').last;

    Dio dio = Dio();
    await dio.get(imageUrl, options: Options(responseType: ResponseType.bytes)).then((value) {

      String imageBase64 = base64Encode(value.data);
      if(typeImage == 'jpg') {typeImage = 'jpeg';}

      historyMessages.add({
        'role': role,
        'parts': [{'text': text},
          {'inlineData': {
            'mimeType': 'image/$typeImage',
            'data': imageBase64,}}],
      });

      emit(SuccessGenerateHistoryMessagesAppState());
    });

  }



  Future<void> postMessage({
    required String message,
    required String idChat,
  }) async {

    // generate history of messages
    generateHistOfMsgs(role: 'user', text: message);

    await DioHelper.postData(
        pathUrl: '/models/gemini-1.5-flash:generateContent',
        data: {
          'contents': historyMessages,
          'generationConfig': generationConfig,
          'safetySettings': safetySettings,
        }).then((value) async {

      String response = value?.data['candidates'][0]['content']['parts'][0]['text'];

      await addAiMessage(idChat: idChat, message: response, timesTamp: DateTime.timestamp()).then((value) {
        getMessages(idChat: idChat);
      });

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in post message');
      }

      emit(ErrorPostMessageAppState(error));

    });
  }



  void getMessages({
    required String idChat,
    bool isRemoving = false,
}) {

    emit(LoadingGetMessagesAppState());

    FirebaseFirestore.instance.collection('users').doc(uId).collection('chats').doc(idChat).
    collection('messages').orderBy('times_tamp').get().then((value) async {

      idMessages = [];
      if(!isRemoving) {messages = [];}
      selectChatMessages = [];
      historyMessages = [];

      for(var element in value.docs) {
        idMessages.add(element.id);

        if(!isRemoving) {
          messages.add(element.data());
        } else {
          selectChatMessages.add(element.data());
        }
      }

      // generate history of messages
      for(var msg in messages) {
        if(msg['is_user']) {
          if(msg['image_url'] == '' || msg['image_url'] == null) {
            generateHistOfMsgs(role: 'user', text: msg['message']);
          } else {
            await Future.wait([
              generateHistOfImgMsg(role: 'user',
                  imageUrl: msg['image_url'],
                  text: msg['message'])]);
          }
        } else {
          generateHistOfMsgs(role: 'model', text: msg['message']);
        }
      }

      // if(kDebugMode) {
      //   print(historyMessages);
      // }

      emit(SuccessGetMessagesAppState());

    });

  }


  Future<void> removeMessage({
    required String idChat,
    required String idMessage,
  }) async {

      await FirebaseFirestore.instance.collection('users').doc(uId).collection('chats').doc(idChat).
      collection('messages').doc(idMessage).delete().then((value) {

        emit(SuccessRemoveMessageAppState());

      }).catchError((error) {

        if(kDebugMode) {
          print('${error.toString()} --> in remove all messages');
        }

        emit(ErrorRemoveMessageAppState(error));

      });
  }


  void clearChats() {
    idChats.clear();
    chats.clear();
    emit(SuccessClearAppState());
  }


  void clearMessages() {
    messages.clear();
    idMessages.clear();
    selectChatMessages.clear();
    historyMessages.clear();
    emit(SuccessClearAppState());
  }



  void renameChat({
    required String idChat,
    required String name,
}) async {

    emit(LoadingRenameChatAppState());

    await FirebaseFirestore.instance.collection('users').doc(uId).collection('chats').doc(idChat).update({
      'name': name,
      'name_lowercase': name.toLowerCase(),
    }).then((value) {

      emit(SuccessRenameChatAppState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in rename chat');
      }

      emit(ErrorRenameChatAppState(error));

    });


  }


  void removeChat({
    required String idChat,
    bool isChatSelected = false,
  }) async {

    emit(LoadingRemoveChatAppState());

    if(idMessages.isNotEmpty) {
      await removeAllMessages(idChat: idChat);
    }

    await FirebaseFirestore.instance.collection('users').doc(uId).collection('chats').doc(idChat)
        .delete().then((value) {

      getChats();
      if(isChatSelected) {getMessages(idChat: idChat);}
      emit(SuccessRemoveChatAppState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in remove chat');
      }

      emit(ErrorRemoveChatAppState(error));

    });

  }


  String decodeImageUrl(String url) {
    final String imageDecoder = Uri.decodeFull(url);
    final String fileName = Uri.parse(imageDecoder).pathSegments.last;
    return fileName;
  }


  Future<void> removeAllMessages({
    required String idChat,
}) async {

    for(var msg in selectChatMessages) {

      if(msg['is_user'] == true && msg['image_url'] != '' && msg['image_url'] != null) {

        String image = decodeImageUrl(msg['image_url']);

        firebase_storage.FirebaseStorage.instance.ref().child('chats/images/$image').delete().then((value) {

          emit(SuccessRemoveImageStoredAppState());
        }).catchError((err) {

          emit(ErrorRemoveImageStoredAppState(err));
        });
      }
    }

    for(var id in idMessages) {

      await FirebaseFirestore.instance.collection('users').doc(uId).collection('chats').doc(idChat).
      collection('messages').doc(id).delete().then((value) {

        emit(SuccessRemoveAllMessagesAppState());

      }).catchError((error) {

        if(kDebugMode) {
          print('${error.toString()} --> in remove all messages');
        }

        emit(ErrorRemoveAllMessagesAppState(error));

      });
    }

  }



  var picker = ImagePicker();

  XFile? image;

  XFile? imageUpload;

  Future<void> getImage(source) async {

    try {

      final pickedFile = await picker.pickImage(source: source);

      if(pickedFile != null) {
        if(File(pickedFile.path).lengthSync() < 5242880) {
          image = XFile(pickedFile.path);
          imageUpload = image;
          emit(SuccessGetImageAppState());
        } else {
          emit(ErrorGetImageAppState('file-size'));
        }
      } else {
        emit(ErrorGetImageAppState('Error ...'));
      }

    } catch (e) {

      emit(ErrorGetImageAppState(e.toString()));

    }


  }


  String statusText = 'Waiting ...';


  void uploadAndGetImageUrl({
    required String idChat,
    required String message,
    required dynamic timesTamp,
}) {

    String typeImage = imageUpload!.path.split('.').last;

    firebase_storage.FirebaseStorage.instance.ref().child('chats/images/${Uri.file(imageUpload!.path).pathSegments.last}')
        .putFile(File(imageUpload!.path)).then((v) async {

          statusText = 'Analyzing image ...';
          emit(SuccessChangeStatusTextAppState());

          await v.ref.getDownloadURL().then((value) async {

            await addUserMessage(idChat: idChat, message: message, timesTamp: timesTamp, imageUrl: value).then((value) {
              getMessages(idChat: idChat);
            });

            await postMessageTextWithImage(messageText: message, imageUrl: value, typeImage: typeImage, idChat: idChat);

            imageUpload = null;

            statusText = 'Waiting ...';

            emit(SuccessGetImageDownloadUrlAppState());

          }).catchError((err) {

            emit(ErrorGetImageDownloadUrlAppState(err));

          });

    }).catchError((error) {

      emit(ErrorUploadAndGetImageUrlAppState(error));

    });
  }


  Future<void> postMessageTextWithImage({
    required String messageText,
    required String imageUrl,
    required String typeImage,
    required String idChat,
  }) async {

    Dio dio = Dio();

    await dio.get(imageUrl, options: Options(responseType: ResponseType.bytes)).then((value) async {

      String imageBase64 = base64Encode(value.data);

      if(typeImage == 'jpg') {
        typeImage = 'jpeg';
      }

      // generate history of messages
      generateHistOfMsgs(role: 'user', text: messageText,
          isImageUploaded: true, extension: typeImage,
          imgBase64: imageBase64);

      await DioHelper.postData(
          pathUrl: '/models/gemini-1.5-flash:generateContent',
          data: {
            'contents': historyMessages,
            'generationConfig': generationConfig,
            'safetySettings': safetySettings,
          }).then((value) async {

        String response = value?.data['candidates'][0]['content']['parts'][0]['text'];

        await addAiMessage(idChat: idChat, message: response, timesTamp: DateTime.timestamp()).then((value) {
          getMessages(idChat: idChat);
        });

          }).catchError((error) {

        if(kDebugMode) {
          print('${error.toString()} --> in post with text and image message');
        }

        emit(ErrorPostMessageAppState(error));

      });

    }).catchError((error) {

      emit(ErrorGetImageUrlEncodedAppState(error));

    });
  }

  void clearImage({bool isClearAll = false}) {
    image = null;
    if(isClearAll) imageUpload = null;
    emit(SuccessClearAppState());
  }


}