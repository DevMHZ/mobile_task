import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show Bidi;

/// Keep API text and user-entered text readable inside either UI direction.
TextDirection contentDirection(String value, TextDirection fallback) =>
    value.trim().isEmpty
    ? fallback
    : Bidi.startsWithRtl(value)
    ? TextDirection.rtl
    : TextDirection.ltr;
