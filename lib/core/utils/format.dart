const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String isoDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Formats a stored yyyy-MM-dd string for display; returns the input if invalid.
String fmtIsoDay(String s) {
  final d = DateTime.tryParse(s);
  return d == null ? s : fmtDate(d);
}

String fmtTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String timeAgo(DateTime d, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(d);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return fmtDate(d);
}

String zmw(num v) {
  final s = v.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final left = s.length - i;
    buf.write(s[i]);
    if (left > 1 && left % 3 == 1) buf.write(',');
  }
  return 'ZMW $buf';
}

String budgetText(double? min, double? max) {
  if (min == null && max == null) return 'Budget not stated';
  if (min != null && max != null) return '${zmw(min)} to ${zmw(max)}';
  if (min != null) return 'From ${zmw(min)}';
  return 'Up to ${zmw(max!)}';
}

String greeting([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

/// Normalises a Zambian mobile number to nine digits, or returns null if invalid.
String? normaliseZmPhone(String input) {
  var d = input.replaceAll(RegExp(r'[\s\-()]'), '');
  if (d.startsWith('+260')) d = d.substring(4);
  if (d.startsWith('260') && d.length == 12) d = d.substring(3);
  if (d.startsWith('0')) d = d.substring(1);
  return RegExp(r'^[79]\d{8}$').hasMatch(d) ? d : null;
}
