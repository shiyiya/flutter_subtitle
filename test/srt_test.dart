// ignore_for_file: constant_identifier_names

import 'package:flutter_subtitle/flutter_subtitle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Parses SubRip file', () {
    final parsedFile = SubtitleController.string(
      _validSubRip,
      format: SubtitleFormat.srt,
    );

    expect(parsedFile.subtitles.length, 4);

    final Subtitle firstSubtitle = parsedFile.subtitles.first;
    expect(firstSubtitle.number, 1);
    expect(firstSubtitle.start, const Duration(seconds: 6).inMilliseconds);
    expect(firstSubtitle.end,
        const Duration(seconds: 12, milliseconds: 74).inMilliseconds);
    expect(firstSubtitle.text, 'This is a test file');

    final Subtitle secondSubtitle = parsedFile.subtitles[1];
    expect(secondSubtitle.number, 2);
    expect(
      secondSubtitle.start,
      const Duration(minutes: 1, seconds: 54, milliseconds: 724).inMilliseconds,
    );
    expect(
      secondSubtitle.end,
      const Duration(minutes: 1, seconds: 56, milliseconds: 760).inMilliseconds,
    );
    expect(secondSubtitle.text, '- Hello.\n- Yes?');

    final Subtitle thirdSubtitle = parsedFile.subtitles[2];
    expect(thirdSubtitle.number, 3);
    expect(
      thirdSubtitle.start,
      const Duration(minutes: 1, seconds: 56, milliseconds: 884).inMilliseconds,
    );
    expect(
      thirdSubtitle.end,
      const Duration(minutes: 1, seconds: 58, milliseconds: 954).inMilliseconds,
    );
    expect(
      thirdSubtitle.text,
      'These are more test lines\nYes, these are more test lines.',
    );

    final Subtitle fourthSubtitle = parsedFile.subtitles[3];
    expect(fourthSubtitle.number, 4);
    expect(
      fourthSubtitle.start,
      const Duration(hours: 1, minutes: 1, seconds: 59, milliseconds: 84)
          .inMilliseconds,
    );
    expect(
      fourthSubtitle.end,
      const Duration(hours: 1, minutes: 2, seconds: 1, milliseconds: 552)
          .inMilliseconds,
    );
    expect(
      fourthSubtitle.text,
      "- [ Machinery Beeping ]\n- I'm not sure what that was,",
    );
  });

  test('Parses SubRip file with malformed input', () {
    final parsedFile =
        SubtitleController.string(_malformedSubRip, format: SubtitleFormat.srt);

    expect(parsedFile.subtitles.length, 1);

    final Subtitle firstSubtitle = parsedFile.subtitles.single;
    expect(firstSubtitle.number, 2);
    expect(firstSubtitle.start, const Duration(seconds: 15).inMilliseconds);
    expect(firstSubtitle.end,
        const Duration(seconds: 17, milliseconds: 74).inMilliseconds);
    expect(firstSubtitle.text, 'This one is valid');
  });

  test('Parses SubRip file with invalid blanks', () {
    final parsedFile =
        SubtitleController.string(_invalid_blanks, format: SubtitleFormat.srt);

    expect(parsedFile.subtitles.length, 2);
  });
}

// const String _validShortSubRip = '''
// 1
// 00:00:06,000 --> 00:00:12,074
// This is a test file

// 2
// 00:01:54,724 --> 00:01:56,760
// - Hello.
// - Yes?
// ''';

const String _validSubRip = '''
1
00:00:06,000 --> 00:00:12,074
This is a test file

2
00:01:54,724 --> 00:01:56,760
- Hello.
- Yes?

3
00:01:56,884 --> 00:01:58,954
These are more test lines
Yes, these are more test lines.

4
01:01:59,084 --> 01:02:01,552
- [ Machinery Beeping ]
- I'm not sure what that was,

''';

const String _malformedSubRip = '''
1
00:00:06,000--> 00:00:12,074
This one should be ignored because the
arrow needs a space.

2
00:00:15,000 --> 00:00:17,074
This one is valid

3
00:01:54,724 --> 00:01:6,760
This one should be ignored because the
ned time is missing a digit.
''';

const String _invalid_blanks = '''
1
00:00:06,000 --> 00:00:12,074
This is a test file



2
00:01:54,724 --> 00:01:56,760
- Hello.
- Yes?



''';
