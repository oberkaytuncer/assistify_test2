class Errors {
  static String showError(String errorCode) {
    switch (errorCode) {
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        return 'Bu mail adresi zaten kullanılmaktadır. Lütfen farklı bir mail kullanınız.';
        break;
      default: 
      return 'Bir hata oluştu';
    }
  } //static method yapınca bu sınıftan bir nesne üretmeden direk bu methoda erişebiliyorsun

}
