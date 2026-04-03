/// Wind-down routine before sleep.
class WindDownRoutine {
  final int durationMinutes;
  final List<WindDownStep> steps;

  const WindDownRoutine({
    required this.durationMinutes,
    required this.steps,
  });

  static WindDownRoutine get defaultRoutine {
    return const WindDownRoutine(
      durationMinutes: 30,
      steps: [
        WindDownStep(
          title: 'Dim Your Lights',
          description: 'Reduce light exposure to signal your body it is time to wind down.',
          durationMinutes: 5,
          icon: 'lightbulb',
        ),
        WindDownStep(
          title: 'Put Away Screens',
          description: 'Blue light suppresses melatonin. Switch to a book or audio.',
          durationMinutes: 5,
          icon: 'phone_disabled',
        ),
        WindDownStep(
          title: 'Deep Breathing',
          description: 'Breathe in for 4 counts, hold for 7, exhale for 8. Repeat 4 times.',
          durationMinutes: 5,
          icon: 'air',
        ),
        WindDownStep(
          title: 'Body Scan',
          description: 'Starting from your toes, tense and release each muscle group.',
          durationMinutes: 5,
          icon: 'accessibility_new',
        ),
        WindDownStep(
          title: 'Cool Down',
          description: 'Lower your room temperature to 18-20 degrees C for optimal sleep.',
          durationMinutes: 5,
          icon: 'thermostat',
        ),
        WindDownStep(
          title: 'Settle In',
          description: 'Get comfortable. Close your eyes. Let your thoughts drift.',
          durationMinutes: 5,
          icon: 'bedtime',
        ),
      ],
    );
  }
}

class WindDownStep {
  final String title;
  final String description;
  final int durationMinutes;
  final String icon;

  const WindDownStep({
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.icon,
  });
}
