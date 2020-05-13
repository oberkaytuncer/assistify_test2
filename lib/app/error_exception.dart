class Errors {
  static String showError(String errorCode) {
    switch (errorCode) {
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        return 'Bu mail adresi zaten kullanılmaktadır. Lütfen farklı bir mail kullanınız.';
        break;
      case 'ERROR_USER_NOT_FOUND':
        return 'Bu kullanıcı sistemde bulunmamaktadır. Lütfen kullanıcı oluşturunuz.';
        break;



      default: 
      return 'Bir hata oluştu';
      
    }
  } //static method yapınca bu sınıftan bir nesne üretmeden direk bu methoda erişebiliyorsun

}
