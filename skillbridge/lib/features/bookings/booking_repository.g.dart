// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookingRepository)
final bookingRepositoryProvider = BookingRepositoryProvider._();

final class BookingRepositoryProvider
    extends
        $FunctionalProvider<
          BookingRepository,
          BookingRepository,
          BookingRepository
        >
    with $Provider<BookingRepository> {
  BookingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingRepositoryHash();

  @$internal
  @override
  $ProviderElement<BookingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BookingRepository create(Ref ref) {
    return bookingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingRepository>(value),
    );
  }
}

String _$bookingRepositoryHash() => r'341659f190c532580ef7eea24fb7fbc186118057';

@ProviderFor(mySessions)
final mySessionsProvider = MySessionsFamily._();

final class MySessionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BookingModel>>,
          List<BookingModel>,
          Stream<List<BookingModel>>
        >
    with
        $FutureModifier<List<BookingModel>>,
        $StreamProvider<List<BookingModel>> {
  MySessionsProvider._({
    required MySessionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'mySessionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mySessionsHash();

  @override
  String toString() {
    return r'mySessionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<BookingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<BookingModel>> create(Ref ref) {
    final argument = this.argument as String;
    return mySessions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MySessionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mySessionsHash() => r'83590dde20852682ac4e5ae4c2fbf37bcda736f1';

final class MySessionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<BookingModel>>, String> {
  MySessionsFamily._()
    : super(
        retry: null,
        name: r'mySessionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MySessionsProvider call(String userId) =>
      MySessionsProvider._(argument: userId, from: this);

  @override
  String toString() => r'mySessionsProvider';
}
