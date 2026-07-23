abstract class AtlasEngine<TInput, TResult> {
  const AtlasEngine();

  // Stable identifier used by diagnostics, logs, registries,
  // orchestration, and future Atlas Council capabilities.
  String get id;

  // Human-readable engine name.
  String get name;

  // Short explanation of the engine's responsibility.
  String get description;

  // Engine implementation version.
  //
  // This allows Atlas to track changes in rules and compare
  // results produced by different engine versions later.
  String get version;

  // Validates whether the supplied input contains everything
  // required for this engine to safely process it.
  //
  // An empty list means the input is valid.
  // Each returned string should describe one validation issue.
  List<String> validateInput(TInput input);

  // Returns true when the engine can safely process the input.
  bool canProcess(TInput input) {
    return validateInput(input).isEmpty;
  }

  // Executes the engine's core domain logic.
  //
  // Implementations should remain independent from Flutter,
  // screens, widgets, navigation, and presentation concerns.
  TResult process(TInput input);

  // Validates the input before executing the engine.
  //
  // Analysts and orchestrators should normally call this method
  // instead of calling process directly.
  TResult processChecked(TInput input) {
    final issues = validateInput(input);

    if (issues.isNotEmpty) {
      throw ArgumentError(
        'Unable to run $name.\n'
            '${issues.map((issue) => '- $issue').join('\n')}',
      );
    }

    return process(input);
  }

  @override
  String toString() {
    return 'AtlasEngine('
        'id: $id, '
        'name: $name, '
        'version: $version'
        ')';
  }
}