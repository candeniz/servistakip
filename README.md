# Servis Takip

Şirketlerin personel/çalışan servislerini **gerçek zamanlı** takip etmesini sağlayan,
**çok kiracılı (multi-tenant)** ve **rol bazlı** production-ready mobil uygulama + backend platformu.

> **Mobil uygulama Flutter + Dart ile geliştirilmiştir.** Backend FastAPI'dir. Mobil uygulama
> backend olmadan da (mock mod) çalışır; böylece ilk açılışta demo senaryosu doğrudan incelenebilir.

---

## İçindekiler
- [Projenin Amacı](#projenin-amacı)
- [Teknoloji Yığını](#teknoloji-yığını)
- [Klasör Yapısı](#klasör-yapısı)
- [Roller ve Yetkiler](#roller-ve-yetkiler)
- [Kurulum](#kurulum)
- [Environment Değişkenleri](#environment-değişkenleri)
- [Mobil Uygulamayı Çalıştırma](#mobil-uygulamayı-çalıştırma)
- [Backend'i Çalıştırma](#backendi-çalıştırma)
- [Docker Kullanımı](#docker-kullanımı)
- [Veritabanı Migration İşlemleri](#veritabanı-migration-işlemleri)
- [Demo Hesapları](#demo-hesapları)
- [Testleri Çalıştırma](#testleri-çalıştırma)
- [Harita API Anahtarı Ekleme](#harita-api-anahtarı-ekleme)
- [Push Notification (FCM) Kurulumu](#push-notification-fcm-kurulumu)
- [Gerçek Zamanlı Mimari](#gerçek-zamanlı-mimari)
- [Güvenlik Notları](#güvenlik-notları)
- [Production Ortamına Geçiş Notları](#production-ortamına-geçiş-notları)

---

## Projenin Amacı

Uygulama; süper admin, şirket yöneticisi, operasyon yetkilisi, şoför ve yolcu rolleri için
ayrı deneyimler sunar:

- **Yöneticiler** araç/şoför/güzergâh/servis tanımlar, canlı haritadan takip eder, duyuru gönderir.
- **Şoförler** kendilerine atanmış servisi başlatır, konum paylaşır, yolcu biniş durumunu işaretler.
- **Yolcular** servislerinin canlı konumunu, tahmini varış süresini (ETA) ve kalan durak sayısını görür.
- **Süper admin** müşteri şirketleri (tenant) ve platform genelini yönetir.

## Teknoloji Yığını

**Mobil (Flutter):**
- Flutter + Dart
- State management: **Riverpod**
- Navigasyon: **GoRouter** (rol bazlı redirect guard)
- API: **Dio** (access/refresh token interceptor)
- Harita: **google_maps_flutter**
- Konum: **Geolocator** + Android foreground service (arka plan konumu)
- Bildirim: **Firebase Cloud Messaging**
- Gerçek zamanlı: **WebSocket** (web_socket_channel)
- Güvenli depolama: **flutter_secure_storage**

**Backend:** Python · FastAPI · SQLAlchemy 2.0 (async) · Alembic · PostgreSQL + PostGIS ·
Redis (pub/sub) · WebSocket · JWT (access + refresh rotation) · Pydantic · Docker Compose.

## Klasör Yapısı

```
servis-takip/
├─ apps/
│  ├─ mobile/                # Flutter uygulaması
│  │  └─ lib/
│  │     ├─ core/            # config, tema (colors/typography/spacing), sabitler, utils
│  │     ├─ data/
│  │     │  ├─ models/       # AuthUser, Tenant, ServiceTrip, Stop, EtaResult ...
│  │     │  ├─ services/     # dio_client, auth, data, ws_client, location, notification, token_store
│  │     │  ├─ eta/          # EtaProvider arayüzü + Mock/Google/Mapbox
│  │     │  ├─ simulation/   # araç hareket simülasyon motoru
│  │     │  └─ mock/         # demo veriler (Atlas Teknoloji senaryosu)
│  │     ├─ providers/       # Riverpod (auth, simulation, data, live_trip)
│  │     ├─ router/          # GoRouter + rol bazlı redirect guard
│  │     ├─ widgets/         # yeniden kullanılabilir UI bileşenleri
│  │     └─ features/        # ekranlar: auth + super_admin/company_admin/driver/passenger
│  │  └─ test/               # Dart testleri
│  └─ mobile-legacy-rn/      # (arşiv) önceki React Native sürümü — referans amaçlı
├─ services/api/             # FastAPI backend (değişmedi)
│  ├─ app/{core,models,schemas,services,api/routers,ws}
│  ├─ alembic/               # migration'lar
│  └─ tests/                 # pytest
├─ packages/shared/          # (legacy) RN sürümünün paylaşılan TS tipleri
├─ docker-compose.yml        # postgis + redis + api
├─ .env.example
└─ README.md
```

## Roller ve Yetkiler

| Rol | Değer | Navigasyon (alt sekmeler) |
|-----|-------|------------|
| Süper Admin | `super_admin` | Dashboard · Müşteriler · Operasyon · Destek · Ayarlar |
| Yönetici | `company_admin` | Ana Sayfa · Canlı · Servisler · Kişiler · Yönetim |
| Operasyon Yetkilisi | `operations_manager` | (Yönetici arayüzü) |
| Şoför | `driver` | Ana Sayfa · Yolculuk · Yolcular · Bildirimler · Profil |
| Yolcu | `passenger` | Ana Sayfa · Servisim · Bildirimler · Geçmiş · Profil |

Giriş tek noktadan yapılır; kullanıcı rolüne göre GoRouter tarafından ilgili route grubuna
yönlendirilir. **Rol ve tenant yetkisi her zaman backend'de doğrulanır**; mobildeki redirect
guard yalnızca UX içindir.

## Kurulum

Önkoşullar: **Flutter SDK ≥ 3.5** (Dart ≥ 3.5), **Docker** (backend için), **Python ≥ 3.11**
(backend'i Docker'sız çalıştıracaksanız).

```bash
# Mobil bağımlılıklar
cd apps/mobile
flutter pub get

# Backend ortam dosyası (kökte)
cd ../..
cp .env.example .env
```

## Environment Değişkenleri

Kök `.env` (Docker/backend), `.env.example` dosyasından türetilir. Öne çıkanlar:

| Değişken | Açıklama |
|----------|----------|
| `DATABASE_URL` | Async DB bağlantısı (asyncpg) |
| `ALEMBIC_DATABASE_URL` | Migration bağlantısı (psycopg, senkron) |
| `REDIS_URL` | Redis pub/sub |
| `JWT_SECRET_KEY` | JWT imzalama anahtarı (**production'da mutlaka değiştirin**) |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Access token ömrü (varsayılan 15 dk) |
| `REFRESH_TOKEN_EXPIRE_DAYS` | Refresh token ömrü (varsayılan 30 gün) |
| `SEED_DEMO_DATA` | `true` ise demo veri yüklenir |

Mobil taraf **`--dart-define`** ile yapılandırılır:

| Değişken | Açıklama |
|----------|----------|
| `USE_MOCK` | `true` (varsayılan) → backend olmadan mock modda çalışır |
| `API_URL` | Backend REST adresi (ör. Android emülatör: `http://10.0.2.2:8000`) |
| `WS_URL` | Backend WebSocket adresi (ör. `ws://10.0.2.2:8000`) |

## Mobil Uygulamayı Çalıştırma

```bash
cd apps/mobile
flutter pub get
flutter run
```

Varsayılan olarak **mock mod** açıktır (`USE_MOCK=true`); uygulama backend olmadan demo
senaryosuyla çalışır. Gerçek backend'e bağlanmak için:

```bash
flutter run \
  --dart-define=USE_MOCK=false \
  --dart-define=API_URL=http://10.0.2.2:8000 \
  --dart-define=WS_URL=ws://10.0.2.2:8000
```

Yayın derlemeleri:
```bash
flutter build apk        # Android
flutter build ios        # iOS (macOS gerekir)
```

## Backend'i Çalıştırma

En kolay yol Docker'dır (aşağıya bakın). Docker'sız yerel çalıştırma:

```bash
cd services/api
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
pip install -e ".[dev]"

# PostgreSQL ve Redis'in çalışıyor olması gerekir; .env'i doldurun.
alembic upgrade head
python -m app.seed
uvicorn app.main:app --reload
```

API dokümantasyonu: `http://localhost:8000/docs`

## Docker Kullanımı

```bash
cp .env.example .env
docker compose up --build
```

Bu komut şunları başlatır:
- **db** — PostgreSQL 16 + PostGIS (5432)
- **redis** — Redis 7 (6379)
- **api** — FastAPI (8000); açılışta otomatik `alembic upgrade head` + demo seed + uvicorn

Sağlık kontrolü: `curl http://localhost:8000/health`

## Veritabanı Migration İşlemleri

```bash
cd services/api
alembic upgrade head                                  # migration'ları uygula
alembic revision --autogenerate -m "aciklama"         # yeni migration üret
alembic downgrade -1                                  # bir alt sürüme dön
```

İlk migration (`0001_initial`) PostGIS eklentisini etkinleştirir ve tüm tabloları oluşturur.

## Demo Hesapları

Tüm hesapların şifresi: **`Demo123!`**

| Rol | E-posta |
|-----|---------|
| Süper Admin | `superadmin@demo.com` |
| Yönetici | `yonetici@demo.com` |
| Şoför | `sofor@demo.com` |
| Yolcu | `yolcu@demo.com` |

**Demo senaryosu (Atlas Teknoloji · ATLAS01):**
Avrupa Yakası Sabah Servisi · Araç `34 ST 2026` · Şoför Mehmet Yılmaz · 8 durak · 17 yolcu.
Yolcunun durağı **Beylikdüzü Meydan**, kalan **4 durak**, tahmini varış **~12 dk**, gecikme **~3 dk**.
Uygulamada araç harita üzerinde hareket eder; ETA, kalan durak ve konum canlı güncellenir
(mock simülasyon motoru — şoför "Servisi Başlat" veya yolcu ekranı açılışında tetiklenir).

## Testleri Çalıştırma

**Mobil (Dart / flutter_test):**
```bash
cd apps/mobile
flutter test
```
Kapsam: rol tanımları, mock login (her rol), ETA hesaplama, erişim kuralları
(şoför/yolcu/tenant izolasyonu), araç simülasyon motoru.

> Not: Bu depo yolunda Türkçe karakter (`ı`) bulunduğu için `flutter analyze`'ın kullandığı LSP
> analiz sunucusu bazı ortamlarda çökebilir. Statik analiz için `dart analyze lib test` komutunu
> kullanın (aynı sonucu verir, sorunsuz çalışır).

**Backend (pytest):**
```bash
cd services/api
pip install -e ".[dev]"
pytest
```
Kapsam: login/refresh/me, şoförün yalnızca atanmış servisi görmesi, yolcunun yalnızca kendi
servisini görmesi, tenant izolasyonu, servis başlat/tamamla, biniş durumu güncelleme, konum
gönderimi (doğruluk filtresi + yetki), ETA hesaplama, WebSocket kanal yetkilendirme.

## Harita API Anahtarı Ekleme

Haritalar `google_maps_flutter` ile gösterilir; karoların görünmesi için Google Maps API anahtarı gerekir:

1. Google Cloud Console'dan **Maps SDK for Android / iOS** anahtarı oluşturun.
2. **Android**: `apps/mobile/android/app/src/main/AndroidManifest.xml` içine `<application>` altına:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY" android:value="ANAHTARINIZ"/>
   ```
3. **iOS**: `apps/mobile/ios/Runner/AppDelegate.swift` içinde `GMSServices.provideAPIKey("ANAHTARINIZ")`.
4. Gerçek yol tabanlı ETA için `EtaProvider` arayüzünü uygulayan `GoogleMapsEtaProvider` /
   `MapboxEtaProvider` (`lib/data/eta/`) etkinleştirilebilir; MVP'de `MockEtaProvider` aktiftir.

## Push Notification (FCM) Kurulumu

1. `flutterfire configure` ile Firebase projesini bağlayın (google-services.json /
   GoogleService-Info.plist üretilir).
2. `lib/data/services/notification_service.dart` içindeki başlatma bloğunu (yorumlu) etkinleştirin:
   `Firebase.initializeApp` + `FirebaseMessaging.instance.requestPermission()` + `getToken()`.
3. Token backend'e `POST /notifications/device-tokens` ile kaydedilir (`DeviceToken` modeli).
4. Desteklenen senaryolar: servis başladı, 5/3 durak kaldı, 10 dk kaldı, durağa yaklaşıyor/ulaştı,
   gecikme, araç/şoför değişti, iptal, yeni duyuru.

> Firebase yapılandırması yoksa `NotificationService.init()` en iyi çaba ile atlanır ve uygulama
> çökmeden çalışır.

## Gerçek Zamanlı Mimari

- Şoför servisi başlatınca konum paylaşımı başlar; konum yalnızca **aktif/gecikmeli** serviste
  gönderilir, servis tamamlanınca durur (`lib/data/services/location_service.dart`, Geolocator +
  Android foreground service ile arka plan desteği).
- Konumlar `POST /trips/{id}/locations` ile gönderilir; **kötü GPS doğruluğu filtrelenir**
  (>60 m reddedilir).
- Backend konumu **Redis pub/sub** üzerinden ilgili kanala yayınlar. WebSocket kanalları:
  - `tenant:{tenant_id}:operations`
  - `trip:{service_trip_id}:location`
  - `user:{user_id}:notifications`
- Her istemci yalnızca **yetkili olduğu kanala** abone olabilir (`app/ws/router.py`). Yolcu yalnızca
  kendi servisinin, şoför yalnızca atandığı servisin konumuna erişir; başka şirket/servis görülemez.
- WebSocket koparsa mobil istemci **exponential backoff** ile yeniden bağlanır
  (`lib/data/services/ws_client.dart`).

## Güvenlik Notları

- Şifreler yalnızca **bcrypt hash** olarak saklanır.
- Mobilde token'lar **flutter_secure_storage** içinde tutulur.
- **Access token kısa ömürlüdür**; refresh token rotation'a uygun mimari kullanılır.
- Client'tan gelen `tenant_id`/`role` değerlerine **güvenilmez**; yetki her istekte DB'deki
  kullanıcı kaydından belirlenir (`app/core/deps.py`).
- Tüm liste/detay sorgularında **tenant izolasyonu** uygulanır.
- API hataları **sistem içi detay sızdırmaz**; hassas veriler loglanmaz; işlemler `AuditLog`'a yazılır.

## Production Ortamına Geçiş Notları

- `JWT_SECRET_KEY`'i güçlü, gizli bir değerle değiştirin; secrets manager kullanın.
- Refresh token için **denylist / rotation kalıcılığı** ekleyin (şu an stateless).
- CORS origin listesini yalnızca gerçek istemcilere daraltın.
- PostgreSQL/Redis'i yönetilen servislerde çalıştırın; DB yedekleme ve PITR yapılandırın.
- Mobil uygulamayı `--dart-define=USE_MOCK=false` ile gerçek backend'e bağlayın.
- Google Maps anahtarını ve FCM (FlutterFire) yapılandırmasını ekleyin.
- API'yi ölçeklerken Redis pub/sub sayesinde birden çok uvicorn/worker örneği çalıştırabilirsiniz.
- Gözlemlenebilirlik: yapılandırılmış loglama, metrik ve hata izleme (ör. Sentry) ekleyin.

---

## Not: React Native arşivi

`apps/mobile-legacy-rn/` ve `packages/shared/` klasörleri, projenin **önceki React Native (Expo)
sürümüdür** ve yalnızca referans amacıyla saklanmaktadır. Aktif mobil uygulama `apps/mobile`
(Flutter) klasörüdür.
