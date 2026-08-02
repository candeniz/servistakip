/// Kullanıcıya gösterilen sabit metinler (Türkçe). Merkezi tutulur.
class S {
  const S._();

  // Uygulama
  static const appName = 'Servis Takip';
  static const tagline = 'Personel servislerini gerçek zamanlı takip edin';

  // Kimlik doğrulama
  static const login = 'Giriş Yap';
  static const email = 'E-posta';
  static const password = 'Şifre';
  static const forgotPassword = 'Şifremi unuttum';
  static const demoHint = 'Demo hesapları aşağıdan seçebilirsiniz';
  static const invalidCredentials = 'E-posta veya şifre hatalı.';
  static const logout = 'Çıkış Yap';

  // Ortak
  static const loading = 'Yükleniyor…';
  static const retry = 'Tekrar Dene';
  static const cancel = 'Vazgeç';
  static const confirm = 'Onayla';
  static const search = 'Ara…';
  static const noData = 'Kayıt bulunamadı';
  static const genericError = 'Bir şeyler ters gitti';

  // Hatalar / durumlar
  static const noInternet = 'İnternet bağlantısı yok. Bağlantınızı kontrol edin.';
  static const apiUnreachable = 'Sunucuya ulaşılamıyor. Lütfen daha sonra tekrar deneyin.';
  static const gpsOff = 'Konum servisi kapalı. Lütfen GPS’i açın.';
  static const locationDenied = 'Konum izni verilmedi.';
  static const notificationDenied = 'Bildirim izni verilmedi.';
  static const driverNoLocation = 'Şoför şu anda konum paylaşmıyor.';
  static const tripNotStarted = 'Servis henüz başlamadı.';
  static const tripCancelled = 'Servis iptal edildi.';
  static const noActiveTrip = 'Aktif servis bulunamadı.';
  static const noAssignedService = 'Size atanmış bir servis bulunmuyor.';
  static const sessionExpired = 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.';
  static const unauthorized = 'Bu ekrana erişim yetkiniz yok.';
  static const wsDisconnected = 'Canlı bağlantı koptu, yeniden bağlanılıyor…';

  // Şoför
  static const startTrip = 'Servisi Başlat';
  static const arriveStop = 'Durağa Vardım';
  static const departStop = 'Duraktan Hareket';
  static const completeTrip = 'Servisi Tamamla';
  static const preTripCheck = 'Servis Öncesi Kontrol';
  static const reportIncident = 'Olay Bildir';
  static const nextStop = 'Sıradaki Durak';

  // Yolcu
  static const myService = 'Servisim';
  static const eta = 'Tahmini Varış';
  static const remainingStops = 'Kalan Durak';
  static const remainingDistance = 'Kalan Mesafe';
  static const delay = 'Gecikme';
  static const absentToday = 'Bugün Binmeyeceğim';
  static const driverInfo = 'Şoför & Araç';
}
