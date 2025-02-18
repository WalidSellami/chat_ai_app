abstract class AppStates {}

class InitialAppState extends AppStates {}

class LoadingGetProfileAppState extends AppStates {}

class SuccessGetProfileAppState extends AppStates {}

class ErrorGetProfileAppState extends AppStates {

  dynamic error;
  ErrorGetProfileAppState(this.error);

}


class LoadingSignOutAppState extends AppStates {}

class SuccessSignOutAppState extends AppStates {}

class ErrorSignOutAppState extends AppStates {

  dynamic error;
  ErrorSignOutAppState(this.error);

}

// Change Indexing
class SuccessChangeIndexingAppState extends AppStates {}

// Select and Change Indexing
class SuccessSelectAndChangeIndexingAppState extends AppStates {}

// Add chat
class LoadingAddChatAppState extends AppStates {}

class SuccessAddChatAppState extends AppStates {}

class ErrorAddChatAppState extends AppStates {

  dynamic error;
  ErrorAddChatAppState(this.error);

}

// New chat
class SuccessSetNewChatAppState extends AppStates {}


// Get chats
class LoadingGetChatsAppState extends AppStates {}

class SuccessGetChatsAppState extends AppStates {}


// Rename chat
class LoadingRenameChatAppState extends AppStates {}

class SuccessRenameChatAppState extends AppStates {}

class ErrorRenameChatAppState extends AppStates {

  dynamic error;
  ErrorRenameChatAppState(this.error);

}


// Remove chat
class LoadingRemoveChatAppState extends AppStates {}

class SuccessRemoveChatAppState extends AppStates {}

class ErrorRemoveChatAppState extends AppStates {

  dynamic error;
  ErrorRemoveChatAppState(this.error);

}


// Add user message
class LoadingAddUserMessageAppState extends AppStates {}

class SuccessAddUserMessageAppState extends AppStates {}

class ErrorAddUserMessageAppState extends AppStates {

  dynamic error;
  ErrorAddUserMessageAppState(this.error);

}


// Add ai message
class LoadingAddAiMessageAppState extends AppStates {}

class SuccessAddAiMessageAppState extends AppStates {}

class ErrorAddAiMessageAppState extends AppStates {

  dynamic error;
  ErrorAddAiMessageAppState(this.error);

}


// Send message
class LoadingSendMessageAppState extends AppStates {}

class SuccessSendMessageAppState extends AppStates {}

class ErrorSendMessageAppState extends AppStates {

  dynamic error;
  ErrorSendMessageAppState(this.error);

}



// Post message
class ErrorPostMessageAppState extends AppStates {

  dynamic error;
  ErrorPostMessageAppState(this.error);

}


// Get messages
class LoadingGetMessagesAppState extends AppStates {}

class SuccessGetMessagesAppState extends AppStates {}

class SuccessGenerateHistoryMessagesAppState extends AppStates {}

// Get id messages
class LoadingGetIdMessagesAppState extends AppStates {}

class SuccessGetIdMessagesAppState extends AppStates {}

// Remove last message
class SuccessRemoveMessageAppState extends AppStates {}

class ErrorRemoveMessageAppState extends AppStates {

  dynamic error;
  ErrorRemoveMessageAppState(this.error);

}

// Remove all messages
class LoadingRemoveAllMessagesAppState extends AppStates {}

class SuccessRemoveAllMessagesAppState extends AppStates {}

class ErrorRemoveAllMessagesAppState extends AppStates {

  dynamic error;
  ErrorRemoveAllMessagesAppState(this.error);

}


// Search Chat
class SuccessSearchChatAppState extends AppStates {}

class ErrorSearchChatAppState extends AppStates {

  dynamic error;
  ErrorSearchChatAppState(this.error);

}


// Looping
class SuccessLoopingAppState extends AppStates {}


// Clear
class SuccessClearAppState extends AppStates {}


// Get Image
class SuccessGetImageAppState extends AppStates {}

class ErrorGetImageAppState extends AppStates {

  dynamic error;
  ErrorGetImageAppState(this.error);

}


// Upload And Get ImageUrl
class SuccessUploadAndGetImageUrlAppState extends AppStates {}

class SuccessGetImageDownloadUrlAppState extends AppStates {}

class ErrorUploadAndGetImageUrlAppState extends AppStates {

  dynamic error;
  ErrorUploadAndGetImageUrlAppState(this.error);

}

class ErrorGetImageDownloadUrlAppState extends AppStates {

  dynamic error;
  ErrorGetImageDownloadUrlAppState(this.error);

}

class ErrorGetImageUrlEncodedAppState extends AppStates {

  dynamic error;
  ErrorGetImageUrlEncodedAppState(this.error);

}


// Remove Image Stored
class SuccessRemoveImageStoredAppState extends AppStates {}

class ErrorRemoveImageStoredAppState extends AppStates {

  dynamic error;
  ErrorRemoveImageStoredAppState(this.error);

}

// Status Text
class SuccessChangeStatusTextAppState extends AppStates {}