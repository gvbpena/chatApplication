// ignore: camel_case_types
class Chat_messages {
  Chat_messages({
    required this.message,
    required this.receiver,
    required this.sender,
    required this.dateTime,
  });

  String message;
  String receiver;
  String sender;
  String dateTime;

  factory Chat_messages.fromJson(Map<String, dynamic> json) => Chat_messages(
        message: json["message"],
        receiver: json["receiver"],
        sender: json["sender"],
        dateTime: json["dateTime"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "receiver": receiver,
        "sender": sender,
        "dateTime": dateTime,
      };
}
