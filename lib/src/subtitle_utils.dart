import 'dart:convert';

import '../flutter_subtitle.dart';

List<Subtitle> parseSubtitleString(String data, SubtitleFormat format) {
  switch (format) {
    case SubtitleFormat.webvtt:
      return parseFromWebVTTString(data);
    case SubtitleFormat.srt:
      return parseFromSubRipString(data);
    default:
      return [];
  }
}

// video player
List<List<String>> readSubtitleFile(String file) {
  final List<String> lines = LineSplitter.split(file).toList();

  final List<List<String>> subtitleStrings = <List<String>>[];
  List<String> currentCaption = <String>[];
  int lineIndex = 0;
  for (final String line in lines) {
    final bool isLineBlank = line.trim().isEmpty;
    if (!isLineBlank) {
      currentCaption.add(line);
    }

    if (isLineBlank || lineIndex == lines.length - 1) {
      subtitleStrings.add(currentCaption);
      currentCaption = <String>[];
    }

    lineIndex += 1;
  }

  return subtitleStrings;
}

List<Subtitle> parseFromWebVTTString(String data) {
  final subtitles = <Subtitle>[];
  final captions = RegExp(_webVTTSegment).allMatches(data);

  int subtitleNumber = 1;

  for (final caption in captions) {
    final start = _timestampToMillisecond(caption.groups([2, 3, 4, 5]));
    final end = _timestampToMillisecond(caption.groups([6, 7, 8, 9]));
    final text = caption.group(11);
    if (start == null || end == null) {
      continue;
    }

    subtitles.add(Subtitle(
      number: int.tryParse(caption.group(1) ?? '') ?? subtitleNumber,
      start: start.inMilliseconds,
      end: end.inMilliseconds,
      text: extractTextFromHtml(text ?? ''),
    ));
    subtitleNumber++;
  }

  return subtitles;
}

Duration? _timestampToMillisecond(List<String?> segments) {
  final hours = int.parse(segments[0]?.split(':')[0] ?? '0');
  final minutes = int.parse(segments[1]?.split(':')[0] ?? '0');
  final seconds = int.parse(segments[2] ?? '');
  final milliseconds = int.parse(segments[3] ?? '0');
  if (minutes > 59 || seconds > 59) {
    return null;
  }

  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
  );
}

List<Subtitle> parseFromSubRipString(String data) {
  final List<Subtitle> subtitles = <Subtitle>[];
  final subtitleStrings = readSubtitleFile(data);

  for (final List<String> subtitleLine in subtitleStrings) {
    // invalid blanks
    // https://github.com/shiyiya/flutter_subtitle/issues/3
    if (subtitleLine.isEmpty) {
      continue;
    }

    final range = rangefromSubRipString(subtitleLine[1]);

    if (range == null) {
      continue;
    }

    subtitles.add(Subtitle(
      number: int.parse(subtitleLine[0]),
      start: range[0].inMilliseconds,
      end: range[1].inMilliseconds,
      text: extractTextFromHtml(subtitleLine.sublist(2).join('\n')),
    ));
  }

  return subtitles;
}

// Parses a time stamp in an SubRip file into a Duration.
// For example:
//
// _parseSubRipTimestamp('00:01:59,084')
// returns
// Duration(hours: 0, minutes: 1, seconds: 59, milliseconds: 084)
Duration? parseSubRipTimestamp(String timestampString) {
  if (!RegExp(_subRipTimeStamp).hasMatch(timestampString)) {
    return null;
  }

  final List<String> commaSections = timestampString.split(',');
  final List<String> hoursMinutesSeconds = commaSections[0].split(':');

  final int hours = int.parse(hoursMinutesSeconds[0]);
  final int minutes = int.parse(hoursMinutesSeconds[1]);
  final int seconds = int.parse(hoursMinutesSeconds[2]);
  final int milliseconds = int.parse(commaSections[1]);

  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
  );
}

// 00:00:06,000 --> 00:00:12,074
List<Duration>? rangefromSubRipString(String line) {
  final RegExp format = RegExp(_subRipTimeStamp + _arrow + _subRipTimeStamp);

  if (!format.hasMatch(line)) {
    return null;
  }

  final List<String> times = line.split(_arrow);

  final Duration? start = parseSubRipTimestamp(times[0]);
  final Duration? end = parseSubRipTimestamp(times[1]);

  if (start == null || end == null) {
    return null;
  }

  return [start, end];
}

String extractTextFromHtml(String htmlString) {
  final RegExp exp = RegExp(_html, multiLine: true, caseSensitive: true);
  return htmlString.replaceAll(exp, '');
}

const String _subRipTimeStamp = r'\d\d:\d\d:\d\d,\d\d\d';

const String _arrow = r' --> ';

const String _webVTTSegment = r'(?:(.+?)(?:\r\n?|\n))?'
    r'(\d{2,}:)?(\d{2}:)(\d{2})\.(\d+)\s+-->\s+(\d{2,}:)?(\d{2}:)(\d{2})\.(\d+)\s*?([^\r\n]*?)(?:\r\n?|\n)'
    r'(?<content>[^\0]*?)'
    r'(?=(?:\r\n?|\n)*?(?:$|(?:.+?(?:\r\n?|\n))?.*?-->))';

const String _html = r'<[^>]*>|&[^;]+;';
