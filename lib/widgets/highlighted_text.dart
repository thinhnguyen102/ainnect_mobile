import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String keyword;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighlightedText({
    Key? key,
    required this.text,
    required this.keyword,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (keyword.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final defaultStyle = style ?? const TextStyle();
    final defaultHighlightStyle = highlightStyle ??
        const TextStyle(
          backgroundColor: Color(0xFFFDE68A),
          fontWeight: FontWeight.w600,
          color: Color(0xFF92400E),
        );

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerKeyword, start);
      if (index == -1) {
        // Add remaining text
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: defaultStyle));
        }
        break;
      }

      // Add text before keyword
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: defaultStyle));
      }

      // Add highlighted keyword
      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: defaultHighlightStyle,
      ));

      start = index + keyword.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
