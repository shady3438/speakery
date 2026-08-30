# Speakery Gelistirici Devir Rehberi

Bu belge, projeyi devralacak gelistiricinin guvenli ve hizli sekilde
calisabilmesi icin gerekenleri tek yerde toplar.

## Kaynak Kod

Public depo:

https://github.com/shady3438/speakery

Ilk kurulum:

```bash
git clone https://github.com/shady3438/speakery.git
cd speakery
flutter pub get
cd functions
npm ci
cd ..
```

Gereken araclar:

- Flutter 3 ve uyumlu Dart SDK
- Android Studio veya Android SDK komut satiri araclari
- Node.js 20
- Firebase CLI
- FlutterFire CLI
- iOS gelistirme icin macOS, Xcode ve Apple Developer erisimi

## Proje Sahibinin Vermesi Gereken Erisimler

Kod okunabilir ve indirilebilir durumdadir. Depoya dogrudan kod gonderebilmek
icin gelistiricinin GitHub kullanici adi repository collaborator olarak
eklenmelidir.

Canli Firebase projesi `speakery-gokay` projesidir. Gelistiricinin Google
hesabi Firebase Console icindeki Project settings > Users and permissions
bolumunden eklenmelidir. Yalnizca uygulama gelistirecek kisiye gereken en dar
yetki verilmeli; Functions, Firestore ve Hosting deploy edecek kisiye bu
servisleri yonetebilecek proje yetkileri de verilmelidir.

Play Store veya App Store yayini yapacaksa ayrica su erisimler gerekir:

- Google Play Console kullanici erisimi
- Apple Developer ve App Store Connect kullanici erisimi
- Firebase Authentication, Firestore, Functions ve Hosting erisimi

## Firebase Baglantisi

Firebase erisimi verildikten sonra:

```bash
firebase login
firebase use speakery-gokay
dart pub global activate flutterfire_cli
flutterfire configure --project=speakery-gokay
```

Bu islem yerel Firebase istemci dosyalarini uretir. Uretilen su dosyalar
Git'e eklenmemelidir:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `admin/firebase-config.js`

Android Firebase uygulamasi su an `com.example.speakery`, iOS Firebase
uygulamasi ise `com.example.flutterTemplate` kimligini kullaniyor. Bunlar
magaza yayini oncesinde kalici kimliklerle degistirilecek; degisiklik Firebase
uygulama kayitlariyla birlikte yapilmalidir.

## AI Ayarlari

Mobil uygulamaya OpenAI API anahtari konmaz. Uygulama yalnizca Firebase
Functions uzerinden gecen kimlik dogrulamali endpoint'leri kullanir.

```bash
copy env.example.json env.json
flutter run --dart-define-from-file=env.json
```

Deploy sonrasinda kullanilacak guvenli endpoint adresleri:

```text
https://speakery-gokay.web.app/ai/general
https://speakery-gokay.web.app/ai/writing
https://speakery-gokay.web.app/ai/speaking
https://speakery-gokay.web.app/ai/listening
https://speakery-gokay.web.app/ai/chat
```

31 Agustos 2026 kontrolunde Firebase Hosting ve AI Functions henuz canli
degildi; bu adresler `404` donuyordu. AI'nin calismasi icin secret
tanimlandiktan sonra Functions ve Hosting birlikte deploy edilmelidir.

Backend secret eksikse proje sahibi veya yetkili gelistirici kendi terminalinde
su komutla tanimlar:

```bash
firebase functions:secrets:set OPENAI_API_KEY
```

Anahtar sohbet, e-posta, GitHub issue veya repository uzerinden
paylasilmamalidir.

## Calistirma ve Kontrol

```bash
dart analyze lib
flutter test
flutter run --dart-define-from-file=env.json
```

Android debug kontrolu:

```bash
flutter build apk --debug --dart-define-from-file=env.json
```

Backend kontrolu:

```bash
cd functions
npm run lint
cd ..
```

## Firebase Deploy

Firestore kurallari 30 Agustos 2026 tarihinde `speakery-gokay` projesine
deploy edildi. Functions ve Hosting ise 31 Agustos 2026 kontrolunde henuz
canli degildi. Once ilgili testler calistirilmali, sonra gereken servisler
deploy edilmelidir:

```bash
firebase deploy --only firestore
firebase deploy --only functions
firebase deploy --only hosting
```

Tum servisleri tek seferde deploy etmek icin:

```bash
firebase deploy --only firestore,functions,hosting
```

## Admin Paneli

Admin paneli `admin/` klasorundedir. Kullanici once Firebase Authentication'a
kayit olmali, ardindan admin custom claim verilmelidir:

```bash
cd functions
npm run set-admin -- gelistirici@example.com true
```

Claim verildikten sonra admin panelinde cikis yapilip yeniden girilmelidir.
Admin yetkisi yalnizca gercekten yonetim yapacak hesaplara verilmelidir.

## Kesinlikle Paylasilmayacak Dosyalar

- OpenAI API anahtari
- Firebase service account JSON dosyasi
- Android keystore ve `android/key.properties`
- Apple sertifikalari ve provisioning private key'leri
- Hesap sifreleri veya oturum tokenlari

Firebase istemci konfigurasyonlari uygulamayi calistirmak icin uretilir; yine
de public repoya konmak yerine Firebase erisimi olan gelistiricinin
`flutterfire configure` ile kendi bilgisayarinda uretmesi tercih edilir.

## Ilk Gelistirme Oncelikleri

1. Kalici Android application ID ve iOS bundle ID belirleme.
2. AI icin App Check, kullanici kotasi ve Functions `maxInstances` korumasi.
3. Sifre sifirlama ve e-posta dogrulama.
4. Speaking ekraninda gercek kayit ve konusma tanima.
5. Gercek App Store ve Play Store satin alma sistemi.
6. GitHub Actions ile analyze ve test otomasyonu.
