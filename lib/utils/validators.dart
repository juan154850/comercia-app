bool validateEmail(String email) {
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return emailRegex.hasMatch(email);
}

bool validatePassword(String password) {
  return password.length >= 6;
}
