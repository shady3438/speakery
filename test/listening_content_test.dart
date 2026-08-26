import 'package:flutter_test/flutter_test.dart';

import 'package:speakery/data/listening/listening_content.dart';

void main() {
  test('listening library covers every CEFR level with complete exercises', () {
    const levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    final ids = <String>{};

    for (final level in levels) {
      final missions = listeningMissionsForLevel(level);
      expect(
        missions.length,
        greaterThanOrEqualTo(3),
        reason: '$level needs at least three listening missions.',
      );

      for (final mission in missions) {
        expect(ids.add(mission.id), isTrue, reason: 'Duplicate ${mission.id}');
        expect(mission.transcript.split(' ').length, greaterThanOrEqualTo(10));
        expect(mission.translationTr, isNotEmpty);
        expect(
          '${mission.titleTr} ${mission.subtitleTr} ${mission.translationTr}',
          matches(RegExp('[çğıöşüÇĞİÖŞÜ]')),
          reason: '${mission.id} needs proper Turkish characters.',
        );
        expect(mission.focusOptions.length, greaterThanOrEqualTo(3));
        expect(mission.focusAnswer,
            inInclusiveRange(0, mission.focusOptions.length - 1));
        expect(mission.dictationTarget, isNotEmpty);
        expect(mission.shadowChunk, isNotEmpty);
        expect(mission.dialogueOptions.length, greaterThanOrEqualTo(3));
        expect(
          mission.dialogueAnswer,
          inInclusiveRange(0, mission.dialogueOptions.length - 1),
        );
      }
    }

    expect(listeningMissions.length, greaterThanOrEqualTo(18));
  });
}
