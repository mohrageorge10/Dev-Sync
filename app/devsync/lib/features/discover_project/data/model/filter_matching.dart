/////----Exact Match (Case Insensitive)----/////
bool matchesAny(Set<String> selected, Iterable<String> values) {
  if (selected.isEmpty) return true;
  final lower = values.map((v) => v.toLowerCase()).toSet();
  return selected.any((s) => lower.contains(s.toLowerCase()));
}

/////----Text Contains Any Selected----/////
bool textContainsAny(Set<String> selected, Iterable<String> texts) {
  if (selected.isEmpty) return true;
  final lower = texts.map((t) => t.toLowerCase()).toList();
  return selected.any((s) => lower.any((t) => t.contains(s.toLowerCase())));
}

/////----Search Query Match----/////
bool containsQuery(String query, Iterable<String> texts) {
  if (query.isEmpty) return true;
  final q = query.toLowerCase();
  return texts.any((t) => t.toLowerCase().contains(q));
}