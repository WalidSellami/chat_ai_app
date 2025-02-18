import 'package:animate_do/animate_do.dart';
import 'package:chat_ai/presentation/modules/chatModule/ChatScreen.dart';
import 'package:chat_ai/shared/adaptive/loadingIndicator/LoadingIndicator.dart';
import 'package:chat_ai/shared/components/Components.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/cubits/appCubit/AppCubit.dart';
import 'package:chat_ai/shared/cubits/appCubit/AppStates.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckStates.dart';
import 'package:chat_ai/shared/cubits/themeCubit/ThemeCubit.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchChatScreen extends StatefulWidget {

  const SearchChatScreen({super.key});

  @override
  State<SearchChatScreen> createState() => _SearchChatScreenState();
}

class _SearchChatScreenState extends State<SearchChatScreen> {

  final TextEditingController searchController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    searchController.addListener(() {
      setState(() {});
    });
    super.initState();
  }


  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit, CheckStates>(
      listener: (context, state) {},
      builder: (context, state) {

        var checkCubit = CheckCubit.get(context);

        return BlocConsumer<AppCubit, AppStates>(
          listener: (context, state) {},
          builder: (context, state) {

            var cubit = AppCubit.get(context);

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
                  if(checkCubit.hasInternet) {cubit.getChats();}
                  Future.delayed(const Duration(milliseconds: 300)).then((value) {
                    setState(() {searchController.clear();});
                  });
                },
                child: Scaffold(
                  appBar: defaultAppBar(
                    title: 'Search Chat',
                    onPress: () {
                      if(checkCubit.hasInternet) {cubit.getChats();}
                      Future.delayed(const Duration(milliseconds: 300)).then((value) {
                        setState(() {searchController.clear();});
                      });
                      Navigator.pop(context);
                    },
                  ),
                  body: FadeInRight(
                    duration: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          defaultSearchFormField(
                              text: 'Type Chat Name ...',
                              controller: searchController,
                              type: TextInputType.text,
                              focusNode: focusNode,
                              onChange: (value) {
                                if(checkCubit.hasInternet) {
                                  if(value.isNotEmpty) {cubit.searchChat(chatName: searchController.text);}
                                }
                              },
                            onPress: () {
                                setState(() {searchController.clear();});
                                if(checkCubit.hasInternet) {cubit.getChats();}
                              }
                          ),
                          const SizedBox(
                            height: 30.0,
                          ),
                          Expanded(
                            child: (checkCubit.hasInternet) ?
                            ConditionalBuilder(
                              condition: cubit.groupedChats.isNotEmpty,
                              builder: (context) => ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, i) {
                                  String status = cubit.groupedChats.keys.elementAt(i);
                                  List<dynamic> chats = cubit.groupedChats.values.elementAt(i);
                                  List<String> idChats = cubit.groupedIdChats.values.elementAt(i);

                                  // Inner indexes
                                  Map<int, List<int>> listOfIndex = {
                                    i: List.generate(chats.length, (index) => index),
                                  };

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FadeIn(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: ThemeCubit.get(context).isDarkTheme ?
                                              Colors.grey.shade500 : Colors.grey.shade600,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            int actualIndex = listOfIndex[i]![index];
                                            return buildItemChatSearch(chats[actualIndex], idChats[actualIndex],
                                                i, actualIndex);
                                          },
                                          itemCount: chats.length),
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) => const SizedBox(
                                  height: 24.0,
                                ),
                                itemCount: cubit.groupedChats.length,
                              ),
                              fallback: (context) => (state is LoadingGetChatsAppState) ?
                              Center(child: LoadingIndicator(os: getOs())) :
                              const Center(
                                child: Text(
                                  'There is no chats',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ) :
                            FadeIn(
                              duration: const Duration(milliseconds: 400),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'No Internet',
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4.0,
                                    ),
                                    Icon(
                                      EvaIcons.wifiOffOutline,
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
  }

  Widget buildItemChatSearch(chat, idChat, gIndex, actualIndex) => Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 4.0,
    ),
    child: FadeIn(
      duration: const Duration(milliseconds: 400),
      child: ListTile(
        onTap: () {
          focusNode.unfocus();
          if(CheckCubit.get(context).hasInternet) {
            AppCubit.get(context).getMessages(idChat: idChat);
            navigateAndNotReturn(context: context, screen: ChatScreen(idSearchChat: idChat,));
          } else {
            showFlutterToast(
                message: 'No Internet Connection',
                state: ToastStates.error,
                context: context);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        enableFeedback: true,
        leading: const Icon(
          EvaIcons.chevronRightOutline,
        ),
        title: Text(
          '${chat['name']}',
          maxLines: 1,
          style: const TextStyle(
            fontSize: 15.0,
            letterSpacing: 0.6,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
