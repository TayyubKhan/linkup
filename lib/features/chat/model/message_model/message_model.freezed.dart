// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return _MessageModel.fromJson(json);
}

/// @nodoc
mixin _$MessageModel {
  String get id =>
      throw _privateConstructorUsedError; // Unique ID for the message
  String get text =>
      throw _privateConstructorUsedError; // The content of the message
  String get senderId => throw _privateConstructorUsedError; // ID of the sender
  String get senderName =>
      throw _privateConstructorUsedError; // Name of the sender
  DateTime get timestamp =>
      throw _privateConstructorUsedError; // Time when the message was sent
  bool get isSender =>
      throw _privateConstructorUsedError; // Whether the message is from the local user
  bool get isDocument =>
      throw _privateConstructorUsedError; // Whether the message is from the local user
  bool get isSent => throw _privateConstructorUsedError;

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageModelCopyWith<MessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageModelCopyWith<$Res> {
  factory $MessageModelCopyWith(
          MessageModel value, $Res Function(MessageModel) then) =
      _$MessageModelCopyWithImpl<$Res, MessageModel>;
  @useResult
  $Res call(
      {String id,
      String text,
      String senderId,
      String senderName,
      DateTime timestamp,
      bool isSender,
      bool isDocument,
      bool isSent});
}

/// @nodoc
class _$MessageModelCopyWithImpl<$Res, $Val extends MessageModel>
    implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? senderId = null,
    Object? senderName = null,
    Object? timestamp = null,
    Object? isSender = null,
    Object? isDocument = null,
    Object? isSent = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      senderName: null == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isSender: null == isSender
          ? _value.isSender
          : isSender // ignore: cast_nullable_to_non_nullable
              as bool,
      isDocument: null == isDocument
          ? _value.isDocument
          : isDocument // ignore: cast_nullable_to_non_nullable
              as bool,
      isSent: null == isSent
          ? _value.isSent
          : isSent // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageModelImplCopyWith<$Res>
    implements $MessageModelCopyWith<$Res> {
  factory _$$MessageModelImplCopyWith(
          _$MessageModelImpl value, $Res Function(_$MessageModelImpl) then) =
      __$$MessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String text,
      String senderId,
      String senderName,
      DateTime timestamp,
      bool isSender,
      bool isDocument,
      bool isSent});
}

/// @nodoc
class __$$MessageModelImplCopyWithImpl<$Res>
    extends _$MessageModelCopyWithImpl<$Res, _$MessageModelImpl>
    implements _$$MessageModelImplCopyWith<$Res> {
  __$$MessageModelImplCopyWithImpl(
      _$MessageModelImpl _value, $Res Function(_$MessageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? senderId = null,
    Object? senderName = null,
    Object? timestamp = null,
    Object? isSender = null,
    Object? isDocument = null,
    Object? isSent = null,
  }) {
    return _then(_$MessageModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      senderName: null == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isSender: null == isSender
          ? _value.isSender
          : isSender // ignore: cast_nullable_to_non_nullable
              as bool,
      isDocument: null == isDocument
          ? _value.isDocument
          : isDocument // ignore: cast_nullable_to_non_nullable
              as bool,
      isSent: null == isSent
          ? _value.isSent
          : isSent // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageModelImpl implements _MessageModel {
  const _$MessageModelImpl(
      {required this.id,
      required this.text,
      required this.senderId,
      required this.senderName,
      required this.timestamp,
      required this.isSender,
      required this.isDocument,
      required this.isSent});

  factory _$MessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageModelImplFromJson(json);

  @override
  final String id;
// Unique ID for the message
  @override
  final String text;
// The content of the message
  @override
  final String senderId;
// ID of the sender
  @override
  final String senderName;
// Name of the sender
  @override
  final DateTime timestamp;
// Time when the message was sent
  @override
  final bool isSender;
// Whether the message is from the local user
  @override
  final bool isDocument;
// Whether the message is from the local user
  @override
  final bool isSent;

  @override
  String toString() {
    return 'MessageModel(id: $id, text: $text, senderId: $senderId, senderName: $senderName, timestamp: $timestamp, isSender: $isSender, isDocument: $isDocument, isSent: $isSent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isSender, isSender) ||
                other.isSender == isSender) &&
            (identical(other.isDocument, isDocument) ||
                other.isDocument == isDocument) &&
            (identical(other.isSent, isSent) || other.isSent == isSent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, text, senderId, senderName,
      timestamp, isSender, isDocument, isSent);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      __$$MessageModelImplCopyWithImpl<_$MessageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageModelImplToJson(
      this,
    );
  }
}

abstract class _MessageModel implements MessageModel {
  const factory _MessageModel(
      {required final String id,
      required final String text,
      required final String senderId,
      required final String senderName,
      required final DateTime timestamp,
      required final bool isSender,
      required final bool isDocument,
      required final bool isSent}) = _$MessageModelImpl;

  factory _MessageModel.fromJson(Map<String, dynamic> json) =
      _$MessageModelImpl.fromJson;

  @override
  String get id; // Unique ID for the message
  @override
  String get text; // The content of the message
  @override
  String get senderId; // ID of the sender
  @override
  String get senderName; // Name of the sender
  @override
  DateTime get timestamp; // Time when the message was sent
  @override
  bool get isSender; // Whether the message is from the local user
  @override
  bool get isDocument; // Whether the message is from the local user
  @override
  bool get isSent;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
