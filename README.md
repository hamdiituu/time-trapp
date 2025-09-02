# Time Trapp

Masaüstü için geliştirilmiş modern bir zaman takip uygulaması. Flutter ile geliştirilmiştir ve macOS, Windows ve Linux platformlarında çalışır.

## Özellikler

### 🚀 Temel Özellikler
- **Kolay Başlatma**: Çalışma seanslarınızı tek tıkla başlatın
- **Detaylı Takip**: Amaç, hedef ve link bilgileriyle seanslarınızı kaydedin
- **Gerçek Zamanlı Sayaç**: Aktif seanslarınızı canlı olarak takip edin
- **Geçmiş Görüntüleme**: Tüm çalışma seanslarınızı görüntüleyin

### 📊 Raporlama
- **Günlük Görünüm**: Günlük çalışma sürelerinizi görün
- **Saatlik Dağılım**: Saatlik çalışma dağılımınızı analiz edin
- **İstatistikler**: Toplam süre, seans sayısı ve ortalama süre bilgileri

### 🔗 Webhook Desteği
- **Özelleştirilebilir Webhooklar**: Çalışma verilerinizi dış sistemlere gönderin
- **Çoklu HTTP Metodları**: GET, POST, PUT, PATCH desteği
- **Esnek Veri Gönderimi**: Body veya query parametreleri olarak veri gönderimi
- **Olay Bazlı Tetikleme**: 
  - Seans başlatıldığında
  - Seans durdurulduğunda
  - Uygulama açıldığında
  - Uygulama kapandığında

### ⚙️ Ayarlar
- **Kullanıcı Profili**: Kişiselleştirilmiş deneyim
- **Webhook Yapılandırması**: Detaylı webhook ayarları
- **Veri Yönetimi**: Tüm verileri temizleme seçeneği

## Kurulum

### Gereksinimler
- Flutter SDK (3.4.0 veya üzeri)
- Dart SDK
- Platform bağımlı geliştirme araçları (Xcode, Visual Studio, vb.)

### Adımlar

1. **Projeyi klonlayın**
   ```bash
   git clone <repository-url>
   cd time_trapp
   ```

2. **Bağımlılıkları yükleyin**
   ```bash
   flutter pub get
   ```

3. **Uygulamayı çalıştırın**
   ```bash
   # macOS için
   flutter run -d macos
   
   # Windows için
   flutter run -d windows
   
   # Linux için
   flutter run -d linux
   ```

## Kullanım

### İlk Kullanım
1. Uygulama ilk açıldığında onboarding süreci başlar
2. Adınızı girin ve uygulamayı keşfedin
3. İlk çalışma seansınızı başlatın

### Çalışma Seansı Başlatma
1. Ana sayfada "Başlat" butonuna tıklayın
2. Modal açılacak, gerekli bilgileri doldurun:
   - **Amaç** (zorunlu): Ne üzerinde çalışacaksınız?
   - **Hedef** (zorunlu): Bu seansla neyi başarmak istiyorsunuz?
   - **Link** (isteğe bağlı): İlgili link, repo, döküman vb.
3. "Seansı Başlat" butonuna tıklayın

### Seans Yönetimi
- **Durdurma**: Aktif seansı durdurmak için "Durdur" butonuna tıklayın
- **Görüntüleme**: Ana sayfada son seanslarınızı görüntüleyin
- **Raporlama**: Raporlar sayfasından detaylı analizler yapın

### Webhook Yapılandırması
1. Ayarlar sayfasına gidin
2. Webhook URL'nizi girin
3. HTTP metodunu seçin (GET, POST, PUT, PATCH)
4. Veri gönderme yöntemini belirleyin (Body veya Query)
5. Hangi olaylarda webhook gönderileceğini seçin
6. "Webhook Test Et" ile yapılandırmanızı test edin

## Teknik Detaylar

### Mimari
- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences
- **HTTP İstekleri**: http package
- **Tarih/Saat**: intl package

### Veri Modelleri
- `TaskSession`: Çalışma seansı bilgileri
- `WebhookConfig`: Webhook yapılandırması
- `AppSettings`: Uygulama ayarları

### Servisler
- `StorageService`: Yerel veri yönetimi
- `WebhookService`: Webhook işlemleri
- `TimerProvider`: Zaman takibi ve state yönetimi
- `AppLifecycleService`: Uygulama yaşam döngüsü yönetimi

## Webhook Veri Formatı

### Seans Başlatma
```json
{
  "event": "session_start",
  "sessionId": "1234567890",
  "purpose": "Flutter uygulaması geliştirme",
  "goal": "Ana sayfa tasarımını tamamla",
  "link": "https://github.com/user/repo",
  "startTime": "2024-01-15T10:30:00.000Z",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### Seans Durdurma
```json
{
  "event": "session_stop",
  "sessionId": "1234567890",
  "purpose": "Flutter uygulaması geliştirme",
  "goal": "Ana sayfa tasarımını tamamla",
  "link": "https://github.com/user/repo",
  "startTime": "2024-01-15T10:30:00.000Z",
  "endTime": "2024-01-15T12:15:00.000Z",
  "duration": 6300000,
  "formattedDuration": "01:45:00",
  "timestamp": "2024-01-15T12:15:00.000Z"
}
```

### Uygulama Olayları
```json
{
  "event": "app_open",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## Geliştirme

### Proje Yapısı
```
lib/
├── models/           # Veri modelleri
├── providers/        # State management
├── screens/          # UI ekranları
├── services/         # İş mantığı servisleri
├── widgets/          # Yeniden kullanılabilir widget'lar
└── main.dart         # Ana uygulama dosyası
```

### Katkıda Bulunma
1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## Destek

Herhangi bir sorun veya öneriniz için issue açabilirsiniz.