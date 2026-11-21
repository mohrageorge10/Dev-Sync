/// Lightweight date helpers — no external dependencies.
library;

const _months = [
  '',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// e.g. "Nov 23"
String fmtDateShort(DateTime d) => '${_months[d.month]} ${d.day}';

/// e.g. "Nov 23"  (alias)
String fmtDateShort2(DateTime d) => '${_months[d.month]} ${d.day}';

/// e.g. "Nov 23, 2026"
String fmtDate(DateTime d) => '${_months[d.month]} ${d.day}, ${d.year}';

/// Number of whole days from today until [d]  (negative = overdue).
int daysLeft(DateTime d) => d.difference(DateTime.now()).inDays;

/// Human-readable relative label: "Today", "Tomorrow", "In 3 days", etc.
String relativeDays(DateTime d) {
  final diff = daysLeft(d);
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  if (diff > 0) return 'In $diff days';
  return '${-diff} days ago';
}
