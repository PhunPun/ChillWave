class UsernameValidator {
  static bool isValid(String username){
    return getErrorText(username) == null;
  }
  static getErrorText(String username){
    if(username.isEmpty) return 'Tên không được để trống';
    if(username.length < 3) return 'Tên phải có ít nhất 3 ký tự';
    return null;
  }
}