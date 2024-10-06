// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageViewModelHash() => r'754ae5ad0cba4ab52453c9d99a7a7f85ce5ed872';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$MessageViewModel
    extends BuildlessAutoDisposeAsyncNotifier<List<MessageModel>> {
  late final int chatId;

  FutureOr<List<MessageModel>> build(
    int chatId,
  );
}

/// See also [MessageViewModel].
@ProviderFor(MessageViewModel)
const messageViewModelProvider = MessageViewModelFamily();

/// See also [MessageViewModel].
class MessageViewModelFamily extends Family<AsyncValue<List<MessageModel>>> {
  /// See also [MessageViewModel].
  const MessageViewModelFamily();

  /// See also [MessageViewModel].
  MessageViewModelProvider call(
    int chatId,
  ) {
    return MessageViewModelProvider(
      chatId,
    );
  }

  @override
  MessageViewModelProvider getProviderOverride(
    covariant MessageViewModelProvider provider,
  ) {
    return call(
      provider.chatId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageViewModelProvider';
}

/// See also [MessageViewModel].
class MessageViewModelProvider extends AutoDisposeAsyncNotifierProviderImpl<
    MessageViewModel, List<MessageModel>> {
  /// See also [MessageViewModel].
  MessageViewModelProvider(
    int chatId,
  ) : this._internal(
          () => MessageViewModel()..chatId = chatId,
          from: messageViewModelProvider,
          name: r'messageViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$messageViewModelHash,
          dependencies: MessageViewModelFamily._dependencies,
          allTransitiveDependencies:
              MessageViewModelFamily._allTransitiveDependencies,
          chatId: chatId,
        );

  MessageViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
  }) : super.internal();

  final int chatId;

  @override
  FutureOr<List<MessageModel>> runNotifierBuild(
    covariant MessageViewModel notifier,
  ) {
    return notifier.build(
      chatId,
    );
  }

  @override
  Override overrideWith(MessageViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageViewModelProvider._internal(
        () => create()..chatId = chatId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MessageViewModel, List<MessageModel>>
      createElement() {
    return _MessageViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageViewModelProvider && other.chatId == chatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MessageViewModelRef
    on AutoDisposeAsyncNotifierProviderRef<List<MessageModel>> {
  /// The parameter `chatId` of this provider.
  int get chatId;
}

class _MessageViewModelProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MessageViewModel,
        List<MessageModel>> with MessageViewModelRef {
  _MessageViewModelProviderElement(super.provider);

  @override
  int get chatId => (origin as MessageViewModelProvider).chatId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
