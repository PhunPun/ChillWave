class PasswordValidator {
  static bool isValid(String password) {
    return getErrorText(password) == null;
  }

  static String? getErrorText(String password) {
    if (password.isEmpty) return 'Mật khẩu không được để trống';
    if (password.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'Phải có ít nhất 1 chữ in hoa';
    if (!password.contains(RegExp(r'[a-z]'))) return 'Phải có ít nhất 1 chữ thường';
    if (!password.contains(RegExp(r'[0-9]'))) return 'Phải có ít nhất 1 số';
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')))
      return 'Phải có ít nhất 1 ký tự đặc biệt';

    return null; // hợp lệ
  }
}
