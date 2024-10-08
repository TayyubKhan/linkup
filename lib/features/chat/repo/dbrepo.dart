import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/chat_model.dart';
import '../model/message_model/message_model.dart';

final chatDatabaseProvider = Provider<ChatDatabase>((ref) {
  return ChatDatabase();
});

class ChatDatabase {
  static const _dbName = 'chat_app.db';
  static const _dbVersion = 1;
  static const _chatTable = 'chats';
  static const _messageTable = 'messages';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database and create tables
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<int?> getChatIdByName(String name) async {
    final db = await database;
    final result = await db.query(
      _chatTable,
      where: 'chatName = ?',
      whereArgs: [name],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int; // Return chatId if found
    } else {
      return null; // Return null if not found
    }
  }

  // Create tables for Chat and Message
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_chatTable (
        id INTEGER PRIMARY KEY,
        chatName TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        deviceId TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_messageTable (
        id TEXT PRIMARY KEY,             -- Message ID (string or timestamp)
        chatId INTEGER NOT NULL,         -- Foreign key to the related chat
        text TEXT,                       -- Text content of the message
        senderId TEXT NOT NULL,          -- ID of the sender
        senderName TEXT NOT NULL,        -- Name of the sender
        isSender INTEGER NOT NULL,       -- Whether the message is from the local user (bool converted to int)
        isDocument INTEGER NOT NULL,     -- Whether the message is a document (bool converted to int)
        isSent INTEGER NOT NULL,     -- Whether the message is a document (bool converted to int)
        timestamp INTEGER NOT NULL,      -- Timestamp of message creation in milliseconds
        FOREIGN KEY (chatId) REFERENCES $_chatTable (id) ON DELETE CASCADE  -- Reference to chat table
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> fetchUnsentMessages(
      String chatName) async {
    final db = await database;

    // Query to fetch unsent messages with isSent = 0 and the given chatName
    return await db.rawQuery('''
    SELECT messages.* 
    FROM $_messageTable AS messages
    INNER JOIN $_chatTable AS chats
    ON messages.chatId = chats.id
    WHERE chats.chatName = ? AND messages.isSent = ?
  ''', [chatName, 0]);
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed in the future
  }

// Insert a new chat or return the existing chat's ID
  Future<int> insertChat(Chat chat) async {
    final db = await database;

    // Step 1: Check if chat with the same chatName already exists
    final existingChat = await db.query(
      _chatTable,
      where: 'chatName = ?',
      whereArgs: [chat.chatName],
      limit: 1, // Only fetch one matching chat
    );

    // Step 2: If the chat exists, return its ID
    if (existingChat.isNotEmpty) {
      return existingChat.first['id'] as int;
    }
    // Step 3: If the chat doesn't exist, insert a new chat and return the new chat ID
    final newChatId = await db.insert(
      _chatTable,
      chat.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return newChatId;
  }

  // Insert a new message
  Future<int> insertMessage(MessageModel message, int chatId) async {
    final db = await database;
    return await db.insert(
      _messageTable,
      {
        'id': message.id,
        'chatId': chatId,
        'text': message.text,
        'senderId': message.senderId,
        'senderName': message.senderName,
        'isSender': message.isSender ? 1 : 0, // Convert bool to int (1 or 0)
        'isDocument':
            message.isDocument ? 1 : 0, // Convert bool to int (1 or 0)
        'isSent': message.isSent ? 1 : 0,
        'timestamp': message.timestamp
            .millisecondsSinceEpoch, // Store timestamp as milliseconds
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all chats
  Future<List<Chat>> fetchChats() async {
    final db = await database;
    final chats = await db.query(_chatTable);
    return chats.map((json) => Chat.fromJson(json)).toList();
  }

  // Fetch messages by chat ID
  Future<List<MessageModel>> fetchMessagesByChatId(int chatId) async {
    final db = await database;
    final messages = await db.query(
      _messageTable,
      where: 'chatId = ?',
      whereArgs: [chatId],
    );

    return messages.map((message) {
      final Map<String, dynamic> messageMap =
          Map<String, dynamic>.from(message);

      // Convert integer fields back to boolean
      return MessageModel(
          id: messageMap['id'],
          text: messageMap['text'],
          senderId: messageMap['senderId'],
          senderName: messageMap['senderName'],
          isSender: messageMap['isSender'] ==
              1, // Convert int to bool (1 -> true, 0 -> false)
          isDocument: messageMap['isDocument'] ==
              1, // Convert int to bool (1 -> true, 0 -> false)
          timestamp:
              DateTime.fromMillisecondsSinceEpoch(messageMap['timestamp']),
          isSent: messageMap['isSent'] == 1 // Convert back to DateTime
          );
    }).toList();
  }

  // Update a chat
  Future<int> updateChat(Chat chat) async {
    final db = await database;
    return await db.update(
      _chatTable,
      chat.toJson(),
      where: 'id = ?',
      whereArgs: [chat.id],
    );
  }

  // Update a message
  Future<int> updateMessage(MessageModel message) async {
    final db = await database;
    return await db.update(
      _messageTable,
      {
        'id': message.id,
        'text': message.text,
        'senderId': message.senderId,
        'senderName': message.senderName,
        'isSender': message.isSender ? 1 : 0, // Convert bool to int (1 or 0)
        'isDocument':
            message.isDocument ? 1 : 0, // Convert bool to int (1 or 0)
        'timestamp': message.timestamp
            .millisecondsSinceEpoch, // Store timestamp as milliseconds
        'isSent': message.isSent ? 1 : 0, // Store timestamp as milliseconds
      },
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

// Update message status (e.g., isSent)
  Future<int> updateMessageStatus(String messageId, bool isSent) async {
    final db = await database;

    // Update the isSent status of a message based on the message ID
    return await db.update(
      _messageTable,
      {
        'isSent': isSent ? 1 : 0, // Convert bool to int (1 or 0)
      },
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  // Delete a chat (deletes all related messages due to cascade)
  Future<int> deleteChat(int chatId) async {
    final db = await database;
    return await db.delete(
      _chatTable,
      where: 'id = ?',
      whereArgs: [chatId],
    );
  }

  // Delete a message
  Future<int> deleteMessage(String messageId) async {
    final db = await database;
    return await db.delete(
      _messageTable,
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }
}
