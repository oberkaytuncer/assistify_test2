class Errors {
  static String showError(String errorCode) {
    switch (errorCode) {
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        return 'Bu mail adresi zaten kullanılmaktadır. Lütfen farklı bir mail kullanınız.';
      
      case 'ERROR_USER_NOT_FOUND':
        return 'Bu kullanıcı sistemde bulunmamaktadır. Lütfen kullanıcı oluşturunuz.';

      case 'ERROR_USER_NOT_FOUND':
        return 'Bu kullanıcı sistemde bulunmamaktadır. Lütfen kullanıcı oluşturunuz.';

      case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
        return 'Bu Facebook hesabınızdaki mail adresi daha önce G-Mail veya E-mail yöntemi ile sisteme kaydedilmiştir. Lüften kaydı bulunan mailiniz ile giriş yapınız.';




      default: 
      return 'Bir hata oluştu';
      
    }
  } //static method yapınca bu sınıftan bir nesne üretmeden direk bu methoda erişebiliyorsun

}
