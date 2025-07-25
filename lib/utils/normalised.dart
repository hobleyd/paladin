String getNormalisedString(String label) {
  List<String> parts = label.split(',');
  return '${parts[1].trim()} ${parts[0].trim()}';
}