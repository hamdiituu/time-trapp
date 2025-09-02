# Time Trapp

<div align="center">
  <img src="assets/icon/icon.png" alt="Time Trapp Logo" width="128" height="128">
  <h3>Modern Desktop Time Tracking Application</h3>
  <p>Masaüstü için geliştirilmiş modern bir zaman takip uygulaması</p>
</div>

---

## 🇺🇸 English

**Time Trapp** is a modern time tracking application developed for desktop platforms. Built with Flutter, it runs seamlessly on macOS, Windows, and Linux.

### 🚀 Key Features

#### Core Functionality
- **One-Click Start**: Start your work sessions with a single click
- **Detailed Tracking**: Record sessions with purpose, goals, and link information
- **Real-Time Counter**: Track active sessions in real-time
- **History Viewing**: View all your work sessions

#### 📊 Reporting & Analytics
- **Daily Overview**: See your daily work hours
- **Hourly Distribution**: Analyze your hourly work distribution
- **Statistics**: Total time, session count, and average duration

#### 🔗 Webhook Integration
- **Customizable Webhooks**: Send work data to external systems
- **Multiple HTTP Methods**: Support for GET, POST, PUT, PATCH
- **Flexible Data Sending**: Send data as body or query parameters
- **Event-Based Triggers**:
  - When session starts
  - When session stops
  - When app opens
  - When app closes

#### ⚙️ Settings & Configuration
- **User Profile**: Personalized experience
- **Webhook Configuration**: Detailed webhook settings
- **Data Management**: Clear all data option

### 🛠️ Installation

#### Requirements
- Flutter SDK (3.4.0 or higher)
- Dart SDK
- Platform-specific development tools (Xcode, Visual Studio, etc.)

#### Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd time_trapp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For macOS
   flutter run -d macos
   
   # For Windows
   flutter run -d windows
   
   # For Linux
   flutter run -d linux
   ```

### 📱 Usage

#### First Time Setup
1. When the app opens for the first time, the onboarding process begins
2. Enter your name and explore the app
3. Start your first work session

#### Starting a Work Session
1. Click the "Start" button on the home page
2. A modal will open, fill in the required information:
   - **Purpose** (required): What are you working on?
   - **Goal** (required): What do you want to achieve with this session?
   - **Link** (optional): Related link, repo, documentation, etc.
3. Click "Start Session"

#### Session Management
- **Stop**: Click the "Stop" button to stop an active session
- **View**: View your recent sessions on the home page
- **Reports**: Make detailed analysis from the reports page

#### Webhook Configuration
1. Go to the Settings page
2. Enter your webhook URL
3. Select HTTP method (GET, POST, PUT, PATCH)
4. Determine data sending method (Body or Query)
5. Select which events should trigger webhooks
6. Test your configuration with "Test Webhook"

#### Testing Webhooks Locally
To test webhooks locally, you can use a simple HTTP server:

**Using Node.js:**
```bash
# Install http-server globally
npm install -g http-server

# Start a simple server
http-server -p 3000 --cors
```

**Using Python:**
```bash
# Python 3
python -m http.server 3000

# Python 2
python -m SimpleHTTPServer 3000
```

Then use `http://localhost:3000` as your webhook URL in the app.

**Troubleshooting Localhost Issues:**
If you can access `http://localhost:3000` in your browser but not from the app, try these solutions:

1. **Use 127.0.0.1 instead of localhost:**
   ```
   http://127.0.0.1:3000
   ```

2. **Check your local server is running:**
   ```bash
   # Test with curl
   curl http://localhost:3000
   ```

3. **For macOS users:** Make sure the app has network permissions in System Preferences > Security & Privacy > Privacy > Network.

4. **For Android users:** The app now includes `usesCleartextTraffic="true"` to allow HTTP connections.

**Webhook Behavior:**
- **app_open**: Sent only once when the app is first launched or when resuming from a closed state
- **app_close**: Sent when the app is paused or closed
- **session_start**: Sent when a work session begins
- **session_stop**: Sent when a work session ends
- **test**: Sent only when you click the "Test Webhook" button

### 🔧 Technical Details

#### Architecture
- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences
- **HTTP Requests**: http package
- **Date/Time**: intl package

#### Data Models
- `TaskSession`: Work session information
- `WebhookConfig`: Webhook configuration
- `AppSettings`: Application settings

#### Services
- `StorageService`: Local data management
- `WebhookService`: Webhook operations
- `TimerProvider`: Time tracking and state management
- `AppLifecycleService`: Application lifecycle management

### 📡 Webhook Data Format

#### Session Start
```json
{
  "event": "session_start",
  "sessionId": "1234567890",
  "purpose": "Flutter app development",
  "goal": "Complete main page design",
  "link": "https://github.com/user/repo",
  "startTime": "2024-01-15T10:30:00.000Z",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

#### Session Stop
```json
{
  "event": "session_stop",
  "sessionId": "1234567890",
  "purpose": "Flutter app development",
  "goal": "Complete main page design",
  "link": "https://github.com/user/repo",
  "startTime": "2024-01-15T10:30:00.000Z",
  "endTime": "2024-01-15T12:15:00.000Z",
  "duration": 6300000,
  "formattedDuration": "01:45:00",
  "timestamp": "2024-01-15T12:15:00.000Z"
}
```

#### Application Events
```json
{
  "event": "app_open",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### 🏗️ Development

#### Project Structure
```
lib/
├── models/           # Data models
├── providers/        # State management
├── screens/          # UI screens
├── services/         # Business logic services
├── widgets/          # Reusable widgets
└── main.dart         # Main application file
```

#### Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 🇹🇷 Türkçe

**Time Trapp**, masaüstü platformlar için geliştirilmiş modern bir zaman takip uygulamasıdır. Flutter ile geliştirilmiştir ve macOS, Windows ve Linux'ta sorunsuz çalışır.

### 🚀 Temel Özellikler

#### Ana İşlevsellik
- **Tek Tıkla Başlatma**: Çalışma seanslarınızı tek tıkla başlatın
- **Detaylı Takip**: Amaç, hedef ve link bilgileriyle seanslarınızı kaydedin
- **Gerçek Zamanlı Sayaç**: Aktif seanslarınızı canlı olarak takip edin
- **Geçmiş Görüntüleme**: Tüm çalışma seanslarınızı görüntüleyin

#### 📊 Raporlama ve Analiz
- **Günlük Görünüm**: Günlük çalışma sürelerinizi görün
- **Saatlik Dağılım**: Saatlik çalışma dağılımınızı analiz edin
- **İstatistikler**: Toplam süre, seans sayısı ve ortalama süre bilgileri

#### 🔗 Webhook Entegrasyonu
- **Özelleştirilebilir Webhooklar**: Çalışma verilerinizi dış sistemlere gönderin
- **Çoklu HTTP Metodları**: GET, POST, PUT, PATCH desteği
- **Esnek Veri Gönderimi**: Body veya query parametreleri olarak veri gönderimi
- **Olay Bazlı Tetikleme**:
  - Seans başlatıldığında
  - Seans durdurulduğunda
  - Uygulama açıldığında
  - Uygulama kapandığında

#### ⚙️ Ayarlar ve Yapılandırma
- **Kullanıcı Profili**: Kişiselleştirilmiş deneyim
- **Webhook Yapılandırması**: Detaylı webhook ayarları
- **Veri Yönetimi**: Tüm verileri temizleme seçeneği

### 🛠️ Kurulum

#### Gereksinimler
- Flutter SDK (3.4.0 veya üzeri)
- Dart SDK
- Platform bağımlı geliştirme araçları (Xcode, Visual Studio, vb.)

#### Adımlar

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

### 📱 Kullanım

#### İlk Kurulum
1. Uygulama ilk açıldığında onboarding süreci başlar
2. Adınızı girin ve uygulamayı keşfedin
3. İlk çalışma seansınızı başlatın

#### Çalışma Seansı Başlatma
1. Ana sayfada "Başlat" butonuna tıklayın
2. Modal açılacak, gerekli bilgileri doldurun:
   - **Amaç** (zorunlu): Ne üzerinde çalışacaksınız?
   - **Hedef** (zorunlu): Bu seansla neyi başarmak istiyorsunuz?
   - **Link** (isteğe bağlı): İlgili link, repo, döküman vb.
3. "Seansı Başlat" butonuna tıklayın

#### Seans Yönetimi
- **Durdurma**: Aktif seansı durdurmak için "Durdur" butonuna tıklayın
- **Görüntüleme**: Ana sayfada son seanslarınızı görüntüleyin
- **Raporlama**: Raporlar sayfasından detaylı analizler yapın

#### Webhook Yapılandırması
1. Ayarlar sayfasına gidin
2. Webhook URL'nizi girin
3. HTTP metodunu seçin (GET, POST, PUT, PATCH)
4. Veri gönderme yöntemini belirleyin (Body veya Query)
5. Hangi olaylarda webhook gönderileceğini seçin
6. "Webhook Test Et" ile yapılandırmanızı test edin

#### Webhook'ları Yerel Olarak Test Etme
Webhook'ları yerel olarak test etmek için basit bir HTTP sunucusu kullanabilirsiniz:

**Node.js kullanarak:**
```bash
# http-server'ı global olarak yükleyin
npm install -g http-server

# Basit bir sunucu başlatın
http-server -p 3000 --cors
```

**Python kullanarak:**
```bash
# Python 3
python -m http.server 3000

# Python 2
python -m SimpleHTTPServer 3000
```

Sonra uygulamada webhook URL olarak `http://localhost:3000` kullanın.

**Localhost Sorunları İçin Çözümler:**
Tarayıcıdan `http://localhost:3000` adresine erişebiliyorsanız ama uygulamadan erişemiyorsanız, bu çözümleri deneyin:

1. **localhost yerine 127.0.0.1 kullanın:**
   ```
   http://127.0.0.1:3000
   ```

2. **Yerel sunucunuzun çalıştığından emin olun:**
   ```bash
   # curl ile test edin
   curl http://localhost:3000
   ```

3. **macOS kullanıcıları için:** Sistem Tercihleri > Güvenlik ve Gizlilik > Gizlilik > Ağ bölümünden uygulamanın ağ izinlerine sahip olduğundan emin olun.

4. **Android kullanıcıları için:** Uygulama artık HTTP bağlantılarına izin vermek için `usesCleartextTraffic="true"` ayarını içeriyor.

**Webhook Davranışları:**
- **app_open**: Sadece uygulama ilk açıldığında veya kapalı durumdan geri döndüğünde bir kez gönderilir
- **app_close**: Uygulama duraklatıldığında veya kapandığında gönderilir
- **session_start**: Çalışma seansı başladığında gönderilir
- **session_stop**: Çalışma seansı bittiğinde gönderilir
- **test**: Sadece "Webhook Test Et" butonuna bastığınızda gönderilir

### 🔧 Teknik Detaylar

#### Mimari
- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences
- **HTTP İstekleri**: http package
- **Tarih/Saat**: intl package

#### Veri Modelleri
- `TaskSession`: Çalışma seansı bilgileri
- `WebhookConfig`: Webhook yapılandırması
- `AppSettings`: Uygulama ayarları

#### Servisler
- `StorageService`: Yerel veri yönetimi
- `WebhookService`: Webhook işlemleri
- `TimerProvider`: Zaman takibi ve state yönetimi
- `AppLifecycleService`: Uygulama yaşam döngüsü yönetimi

### 📡 Webhook Veri Formatı

#### Seans Başlatma
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

#### Seans Durdurma
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

#### Uygulama Olayları
```json
{
  "event": "app_open",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

### 🏗️ Geliştirme

#### Proje Yapısı
```
lib/
├── models/           # Veri modelleri
├── providers/        # State management
├── screens/          # UI ekranları
├── services/         # İş mantığı servisleri
├── widgets/          # Yeniden kullanılabilir widget'lar
└── main.dart         # Ana uygulama dosyası
```

#### Katkıda Bulunma
1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 🤝 Destek

Herhangi bir sorun veya öneriniz için issue açabilirsiniz.

---

<div align="center">
  <p>Made with ❤️ using Flutter</p>
</div>