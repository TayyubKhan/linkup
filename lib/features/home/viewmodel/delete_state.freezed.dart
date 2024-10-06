// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delete_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DeleteState {
  List<Chat> get chats =>
      throw _privateConstructorUsedError; // List of all chats
  List<int> get selectedChatIds => throw _privateConstructorUsedError;

  /// Create a copy of DeleteState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeleteStateCopyWith<DeleteState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeleteStateCopyWith<$Res> {
  factory $DeleteStateCopyWith(
          DeleteState value, $Res Function(DeleteState) then) =
      _$DeleteStateCopyWithImpl<$Res, DeleteState>;
  @useResult
  $Res call({List<Chat> chats, List<int> selectedChatIds});
}

/// @nodoc
class _$DeleteStateCopyWithImpl<$Res, $Val extends DeleteState>
    implements $DeleteStateCopyWith<$Res> {
  _$DeleteStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeleteState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chats = null,
    Object? selectedChatIds = null,
  }) {
    return _then(_value.copyWith(
      chats: null == chats
          ? _value.chats
          : chats // ignore: cast_nullable_to_non_nullable
              as List<Chat>,
      selectedChatIds: null == selectedChatIds
          ? _value.selectedChatIds
          : selectedChatIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeleteStateImplCopyWith<$Res>
    implements $DeleteStateCopyWith<$Res> {
  factory _$$DeleteStateImplCopyWith(
          _$DeleteStateImpl value, $Res Function(_$DeleteStateImpl) then) =
      __$$DeleteStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Chat> chats, List<int> selectedChatIds});
}

/// @nodoc
class __$$DeleteStateImplCopyWithImpl<$Res>
    extends _$DeleteStateCopyWithImpl<$Res, _$DeleteStateImpl>
    implements _$$DeleteStateImplCopyWith<$Res> {
  __$$DeleteStateImplCopyWithImpl(
      _$DeleteStateImpl _value, $Res Function(_$DeleteStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeleteState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chats = null,
    Object? selectedChatIds = null,
  }) {
    return _then(_$DeleteStateImpl(
      chats: null == chats
          ? _value._chats
          : chats // ignore: cast_nullable_to_non_nullable
              as List<Chat>,
      selectedChatIds: null == selectedChatIds
          ? _value._selectedChatIds
          : selectedChatIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc

class _$DeleteStateImpl implements _DeleteState {
  const _$DeleteStateImpl(
      {final List<Chat> chats = const [],
      final List<int> selectedChatIds = const []})
      : _chats = chats,
        _selectedChatIds = selectedChatIds;

  final List<Chat> _chats;
  @override
  @JsonKey()
  List<Chat> get chats {
    if (_chats is EqualUnmodifiableListView) return _chats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chats);
  }

// List of all chats
  final List<int> _selectedChatIds;
// List of all chats
  @override
  @JsonKey()
  List<int> get selectedChatIds {
    if (_selectedChatIds is EqualUnmodifiableListView) return _selectedChatIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedChatIds);
  }

  @override
  String toString() {
    return 'DeleteState(chats: $chats, selectedChatIds: $selectedChatIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteStateImpl &&
            const DeepCollectionEquality().equals(other._chats, _chats) &&
            const DeepCollectionEquality()
                .equals(other._selectedChatIds, _selectedChatIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_chats),
      const DeepCollectionEquality().hash(_selectedChatIds));

  /// Create a copy of DeleteState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteStateImplCopyWith<_$DeleteStateImpl> get copyWith =>
      __$$DeleteStateImplCopyWithImpl<_$DeleteStateImpl>(this, _$identity);
}

abstract class _DeleteState implements DeleteState {
  const factory _DeleteState(
      {final List<Chat> chats,
      final List<int> selectedChatIds}) = _$DeleteStateImpl;

  @override
  List<Chat> get chats; // List of all chats
  @override
  List<int> get selectedChatIds;

  /// Create a copy of DeleteState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeleteStateImplCopyWith<_$DeleteStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
