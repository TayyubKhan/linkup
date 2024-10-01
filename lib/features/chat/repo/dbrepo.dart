import 'dart:convert';

import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/chat_model.dart';

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

  // Create tables for Chat and Message
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_chatTable (
        id INTEGER PRIMARY KEY,
        chatName TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
  CREATE TABLE $_messageTable (
    id TEXT PRIMARY KEY,             -- Message ID (string or timestamp)
    chatId INTEGER NOT NULL,         -- Foreign key to the related chat
    author TEXT NOT NULL,            -- ID of the author (user ID)
    text TEXT,                       -- Text content of the message
    type TEXT NOT NULL,              -- Message type (e.g., 'text')
    createdAt INTEGER NOT NULL,      -- Timestamp of message creation in milliseconds
    FOREIGN KEY (chatId) REFERENCES $_chatTable (id) ON DELETE CASCADE  -- Reference to chat table
  )
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed in the future
  }

  // Insert a new chat
  Future<int> insertChat(Chat chat) async {
    final db = await database;
    return await db.insert(
      _chatTable,
      chat.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insert a new message
  Future<int> insertMessage(Message message, int chatId) async {
    final db = await database;
    return await db.insert(
      _messageTable,
      {
        ...message.toJson(), // Include the rest of the message details
        'chatId': chatId, // Add chatId to the message
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

  Future<List<Message>> fetchMessagesByChatId(int chatId) async {
    final db = await database;
    final messages = await db.query(
      _messageTable,
      where: 'chatId = ?',
      whereArgs: [chatId],
    );

    // Create a new list of messages
    return messages.map((message) {
      // Create a new Map from the existing message to avoid modifying the read-only result
      final Map<String, dynamic> messageMap = Map<String, dynamic>.from(message);

      // Parse the 'author' field, which is stored as a string
      String authorString = messageMap['author'] as String;

      // Convert the authorString into a Map
      final authorMap = _parseAuthorString(authorString);

      // Set the 'author' field to the newly parsed Map
      messageMap['author'] = authorMap;

      // Return the Message object using the updated map
      return Message.fromJson(messageMap);
    }).toList();
  }

// Helper function to parse the author string into a Map<String, dynamic>
  Map<String, dynamic> _parseAuthorString(String authorString) {
    // Example implementation to convert a string "{id=user1}" into a Map
    final userId = authorString.replaceAll(RegExp(r'[{}id=]'), '');
    return {'id': userId};
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
  Future<int> updateMessage(Message message) async {
    final db = await database;
    return await db.update(
      _messageTable,
      message.toJson(),
      where: 'id = ?',
      whereArgs: [message.id],
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
  Future<int> deleteMessage(int messageId) async {
    final db = await database;
    return await db.delete(
      _messageTable,
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }
}
