// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skills_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(skillsRepository)
final skillsRepositoryProvider = SkillsRepositoryProvider._();

final class SkillsRepositoryProvider
    extends
        $FunctionalProvider<
          SkillsRepository,
          SkillsRepository,
          SkillsRepository
        >
    with $Provider<SkillsRepository> {
  SkillsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'skillsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$skillsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SkillsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SkillsRepository create(Ref ref) {
    return skillsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SkillsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SkillsRepository>(value),
    );
  }
}

String _$skillsRepositoryHash() => r'1efa7a1f6861244ddb103e62118f36f509c02d99';

@ProviderFor(approvedSkills)
final approvedSkillsProvider = ApprovedSkillsProvider._();

final class ApprovedSkillsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SkillModel>>,
          List<SkillModel>,
          Stream<List<SkillModel>>
        >
    with $FutureModifier<List<SkillModel>>, $StreamProvider<List<SkillModel>> {
  ApprovedSkillsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'approvedSkillsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$approvedSkillsHash();

  @$internal
  @override
  $StreamProviderElement<List<SkillModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SkillModel>> create(Ref ref) {
    return approvedSkills(ref);
  }
}

String _$approvedSkillsHash() => r'082bf2394a7980e867a03b3e19cde8acd24104ed';
