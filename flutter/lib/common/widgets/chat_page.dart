import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/chat_model.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../mobile/pages/home_page.dart';

class ChatPage extends StatelessWidget implements PageShape {
  late final ChatModel chatModel;

  ChatPage({ChatModel? chatModel}) {
    this.chatModel = chatModel ?? gFFI.chatModel;
  }

  @override
  final title = translate("Chat");

  @override
  final icon = Icon(Icons.chat);

  @override
  final appBarActions = [
    PopupMenuButton<int>(
        icon: Icon(Icons.group),
        itemBuilder: (context) {
          // only mobile need [appBarActions], just bind gFFI.chatModel
          final chatModel = gFFI.chatModel;
          return chatModel.messages.entries.map((entry) {
            final id = entry.key;
            final user = entry.value.chatUser;
            return PopupMenuItem<int>(
              child: Text("${user.firstName}   ${user.id}"),
              value: id,
            );
          }).toList();
        },
        onSelected: (id) {
          gFFI.chatModel.changeCurrentID(id);
        })
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: chatModel,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: EdgeInsets.only(top: 14.0, bottom: 14.0, left: 14.0),
        child: Consumer<ChatModel>(
          builder: (context, chatModel, child) {
            final currentUser = chatModel.currentUser;
            return Container(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Theme.of(context).colorScheme.background,
              ),
              child: Stack(
                children: [
                  LayoutBuilder(builder: (context, constraints) {
                    final chat = DashChat(
                      onSend: (chatMsg) {
                        chatModel.send(chatMsg);
                        chatModel.inputNode.requestFocus();
                      },
                      currentUser: chatModel.me,
                      messages: chatModel
                              .messages[chatModel.currentID]?.chatMessages ??
                          [],
                      inputOptions: InputOptions(
                        sendOnEnter: true,
                        focusNode: chatModel.inputNode,
                        inputTextStyle: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color),
                        inputDecoration: isDesktop
                            ? InputDecoration(
                                isDense: true,
                                hintText: translate('Write a message'),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.background,
                                contentPadding: EdgeInsets.all(10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              )
                            : defaultInputDecoration(
                                hintText: translate('Write a message'),
                                fillColor:
                                    Theme.of(context).colorScheme.background,
                              ),
                        sendButtonBuilder: defaultSendButton(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                          color: MyTheme.accent,
                          icon: FluentIcons.send_24_filled,
                        ),
                      ),
                      messageOptions: MessageOptions(
                          showOtherUsersAvatar: false,
                          showOtherUsersName: false,
                          textColor: Colors.white,
                          maxWidth: constraints.maxWidth * 0.7,
                          messageTextBuilder: (message, _, __) {
                            final isOwnMessage =
                                message.user.id == currentUser.id;
                            return Column(
                              crossAxisAlignment: isOwnMessage
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(message.text,
                                    style: TextStyle(color: Colors.white)),
                                Text(
                                  "${message.createdAt.hour}:${message.createdAt.minute.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                ).marginOnly(top: 3),
                              ],
                            );
                          },
                          messageDecorationBuilder: (message, __, ___) {
                            final isOwnMessage =
                                message.user.id == currentUser.id;
                            return defaultMessageDecoration(
                              color: isOwnMessage
                                  ? Colors.blueGrey
                                  : MyTheme.accent,
                              borderTopLeft: 8,
                              borderTopRight: 8,
                              borderBottomRight: isOwnMessage ? 8 : 2,
                              borderBottomLeft: isOwnMessage ? 2 : 8,
                            );
                          }),
                    );
                    return SelectionArea(child: chat);
                  }),
                  desktopType == DesktopType.cm ||
                          chatModel.currentID == ChatModel.clientModeID
                      ? SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.account_circle,
                                  color: MyTheme.accent80),
                              SizedBox(width: 5),
                              Text(
                                "${currentUser.firstName}   ${currentUser.id}",
                                style: TextStyle(color: MyTheme.accent),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
