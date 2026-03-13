import 'package:flutter/material.dart';

/// A row of five emoji buttons for selecting mood on a 1–5 scale.
///
/// | Score | Emoji | Label         |
/// |-------|-------|---------------|
/// | 1     | 😡    | Very negative |
/// | 2     | 🙁    | Negative      |
/// | 3     | 😐    | Neutral       |
/// | 4     | 🙂    | Positive      |
/// | 5     | 😄    | Very positive |
class MoodSelector extends StatelessWidget {
  final int selectedMood;
  final ValueChanged<int> onMoodSelected;

  static const List<_MoodOption> _options = [
    _MoodOption(score: 1, emoji: '😡', label: 'Very negative'),
    _MoodOption(score: 2, emoji: '🙁', label: 'Negative'),
    _MoodOption(score: 3, emoji: '😐', label: 'Neutral'),
    _MoodOption(score: 4, emoji: '🙂', label: 'Positive'),
    _MoodOption(score: 5, emoji: '😄', label: 'Very positive'),
  ];

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _options.map((opt) {
            final isSelected = opt.score == selectedMood;
            return Tooltip(
              message: '${opt.score} – ${opt.label}',
              child: GestureDetector(
                onTap: () => onMoodSelected(opt.score),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        opt.emoji,
                        style: TextStyle(
                          fontSize: isSelected ? 36 : 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${opt.score}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (selectedMood > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                _options[selectedMood - 1].label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MoodOption {
  final int score;
  final String emoji;
  final String label;
  const _MoodOption({
    required this.score,
    required this.emoji,
    required this.label,
  });
}
