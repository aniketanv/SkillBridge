// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reviewRepository)
final reviewRepositoryProvider = ReviewRepositoryProvider._();

final class ReviewRepositoryProvider
    extends
        $FunctionalProvider<
          ReviewRepository,
          ReviewRepository,
          ReviewRepository
        >
    with $Provider<ReviewRepository> {
  ReviewRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReviewRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReviewRepository create(Ref ref) {
    return reviewRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewRepository>(value),
    );
  }
}

String _$reviewRepositoryHash() => r'9074e9261943e5c6b2bb9fdd2f37ccb86cd6f931';

@ProviderFor(teacherReviews)
final teacherReviewsProvider = TeacherReviewsFamily._();

final class TeacherReviewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ReviewModel>>,
          List<ReviewModel>,
          Stream<List<ReviewModel>>
        >
    with
        $FutureModifier<List<ReviewModel>>,
        $StreamProvider<List<ReviewModel>> {
  TeacherReviewsProvider._({
    required TeacherReviewsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'teacherReviewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$teacherReviewsHash();

  @override
  String toString() {
    return r'teacherReviewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ReviewModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ReviewModel>> create(Ref ref) {
    final argument = this.argument as String;
    return teacherReviews(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TeacherReviewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$teacherReviewsHash() => r'27f36e127abd0043fcca6941f4676fb5e3b4af18';

final class TeacherReviewsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<ReviewModel>>, String> {
  TeacherReviewsFamily._()
    : super(
        retry: null,
        name: r'teacherReviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TeacherReviewsProvider call(String teacherId) =>
      TeacherReviewsProvider._(argument: teacherId, from: this);

  @override
  String toString() => r'teacherReviewsProvider';
}
