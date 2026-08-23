# 🌾 GaonGram — Social Feed & Real-Time Agora Calling App

A modern, high-performance Flutter mobile application built with **Clean Architecture**, **BLoC/Cubit State Management**, **Hive Offline-First Local Persistence**, and **1-on-1 Real-Time Agora Video & Voice Calling**.

---

## 📸 Core Features

### 📰 1. Read-Only Social Media Feed & Hive Offline-First Caching
- **API Integration**: Connects to `https://gaongram.com/api/v1/posts/` using Dio with custom interceptors and authentication header support.
- **Offline-First Persistence**: Fetched posts are stored in Hive local storage (`posts_box`). When offline, data loads immediately from cache without any blank screen.
- **Shimmer Skeletons**: Gradient skeleton placeholders displayed during initial feed fetch.
- **Pull-to-Refresh**: Seamlessly triggers feed refresh and updates local Hive cache.
- **Infinite Scroll Pagination**: Automatically loads subsequent pages when scrolling near the bottom without duplicate entries.
- **Offline Mode Indicator**: Displays a clear banner when viewing cached posts offline and an illustrated offline view when no cache is available.
- **401 Fallback & Live Auth**: Automatically handles unauthenticated environments with rich demo posts while supporting live token authentication.

---

### 📞 2. 1-on-1 Agora Real-Time Video & Voice Calling
- **Agora RTC Engine**: Fully configured Agora RTC integration supporting ultra-low latency audio and video streams.
- **Voice Calling (Audio Call)**: Pure audio calling mode with high-definition sound, speakerphone/earpiece switching, and real-time audio muting.
- **Video Calling**: Full-screen remote video rendering (`AgoraVideoView.remote`) with local camera Picture-in-Picture (PiP) preview (`AgoraVideoView(uid: 0)`).
- **In-Call Toolbar Controls**:
  - 🎤 **Mute / Unmute** local microphone.
  - 🔊 **Speakerphone / Earpiece** toggle.
  - 📹 **Camera On / Off** toggle.
  - 🔄 **Flip Camera** (front and rear lens switching).
  - 🔴 **End Call** button (auto-records duration to Hive).
- **Incoming Call Screen**: Animated pulsating circular avatar with **Accept** and **Decline** actions.
- **Direct Calling from Feed**: Call any post author directly from their feed card via Voice or Video.

---

### 📜 3. Local Call History
- **Persistent Storage**: All incoming, outgoing, missed, accepted, and declined calls are logged in Hive (`call_logs_box`).
- **Color-Coded Badges**:
  - 🟢 **Accepted** (Green)
  - 🔴 **Missed** (Red)
  - 🟠 **Declined** (Orange)
- **Call-Back Actions**: Quick-action buttons next to each history log to immediately call back via Voice or Video.
- **Simulate Call Dialog**: Floating action button allowing single-device testing of both incoming voice and video calls.
- **Clear History**: Dedicated option to clear all stored call history with confirmation dialog.

---

## 🏗️ Architecture & Design Pattern

The application strictly adheres to **Clean Architecture** with a feature-first directory layout:

```
lib/
├── core/                               # Core shared infrastructure
│   ├── agora/                          # Agora RTC singleton service
│   │   └── agora_service.dart
│   ├── constants/                      # App constants & .env loader
│   │   ├── app_constants.dart
│   │   └── env_config.dart
│   ├── di/                             # Dependency Injection via GetIt
│   │   └── injection_container.dart
│   ├── error/                          # Failures & Exceptions hierarchy
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/                        # Dio client, Interceptors, NetworkInfo
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   ├── theme/                          # Luxury Dark Theme & typography
│   │   └── app_theme.dart
│   └── utils/                          # Date formatters & Permission helpers
│       ├── date_formatter.dart
│       └── permission_helper.dart
│
├── features/
│   ├── feed/                           # Social Media Feed Feature
│   │   ├── data/
│   │   │   ├── datasources/            # RemoteDataSource & Hive LocalDataSource
│   │   │   ├── models/                 # PostModel & Hive TypeAdapters
│   │   │   └── repositories/           # FeedRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/               # PostEntity & PostUserEntity
│   │   │   ├── repositories/           # FeedRepository interface
│   │   │   └── usecases/               # GetFeedUseCase & RefreshFeedUseCase
│   │   └── presentation/
│   │       ├── cubit/                  # FeedCubit & FeedState
│   │       ├── screens/                # FeedScreen
│   │       └── widgets/                # PostCard, ShimmerPostCard, OfflineIllustration
│   │
│   └── calling/                        # Real-Time Calling Feature
│       ├── data/
│       │   ├── datasources/            # CallLocalDataSource (Hive)
│       │   ├── models/                 # CallLogModel & Hive TypeAdapters
│       │   └── repositories/           # CallRepositoryImpl
│       ├── domain/
│       │   ├── entities/               # CallLogEntity, CallType, CallStatus
│       │   ├── repositories/           # CallRepository interface
│       │   └── usecases/               # GetCallHistory, SaveCallLog, ClearCallHistory
│       └── presentation/
│           ├── cubit/                  # CallHistoryCubit & ActiveCallCubit
│           ├── screens/                # IncomingCallScreen, ActiveCallScreen, CallHistoryScreen
│           └── widgets/                # CallControlButton
│
└── main.dart                           # App Entry Point & Navigation Shell
```

---

## 🛠️ Tech Stack & Dependencies

| Category | Package / Tool | Purpose |
|---|---|---|
| **State Management** | `flutter_bloc` `^8.1.6` | Predictable, reactive state management |
| **Dependency Injection**| `get_it` `^8.3.0` | Service locator for clean dependency wiring |
| **Local Storage** | `hive` `^2.2.3` & `hive_flutter` | Fast, lightweight NoSQL key-value persistence |
| **Real-Time Video/Audio**| `agora_rtc_engine` `^6.5.3` | Real-time audio and video communications |
| **Networking** | `dio` `^5.4.0` | HTTP client with interceptors & timeouts |
| **Connectivity** | `connectivity_plus` `^6.1.5` | Device network connectivity monitoring |
| **Permissions** | `permission_handler` `^11.4.0` | Android & iOS Camera/Mic runtime permissions |
| **Image Caching** | `cached_network_image` `^3.4.1` | Network image caching and placeholder rendering |
| **Shimmer Effect** | `shimmer` `^3.0.0` | Loading skeleton shimmer animation |
| **Typography** | `google_fonts` `^6.3.3` | Premium Inter typography |
| **Environment Config** | `flutter_dotenv` `^5.2.1` | Secure runtime environment variables |
| **Functional Error Handling** | `fpdart` `^1.1.0` | Either type for clean failure/success handling |


---

## 🚀 Getting Started & How to Run

### Prerequisites
- Flutter SDK `>=3.3.0`
- Android Studio / VS Code with Flutter extension
- Android device or emulator with API Level `>= 21` (Camera & Mic enabled)

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/gaongram_chat.git
   cd gaongram_chat
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run build_runner** (if regenerating Hive adapters):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**:
   ```bash
   flutter run
   ```

---

## 📱 How to Test Real-Time Calling Between 2 Devices

To test live audio/video calling between two real physical phones:

1. **Install the app on Phone A and Phone B** (ensure both use the same `.env` credentials).
2. **Phone A**:
   - Navigate to the **Calls** tab.
   - Tap **`New Call`** -> Choose **Voice Call** or **Video Call**.
   - Phone A enters channel `gaongram_main`.
3. **Phone B**:
   - Navigate to the **Calls** tab.
   - Tap **`New Call`** -> Choose the same call type.
   - Phone B enters channel `gaongram_main`.
4. **Live Connected**:
   - Both phones will immediately connect with two-way HD audio and video.
   - Test in-call features: **Mute**, **Speakerphone**, **Flip Camera**, and **End Call**.

---

## 🧪 Verification Scenarios

| Test Case | Steps | Expected Result |
|---|---|---|
| **Feed Loading** | Launch app on Feed tab | Skeleton shimmer appears, then posts render with images, user info, and metrics. |
| **Pull-to-Refresh** | Pull down on the feed | Indicator spins, fresh posts are fetched, and Hive cache is updated. |
| **Infinite Scroll** | Scroll down to the bottom | Next page is requested and appended seamlessly without duplicates. |
| **Offline Mode** | Turn on Airplane Mode & restart app | Cached posts render instantly with the yellow **"Offline Mode"** banner. |
| **Outgoing Voice Call** | Tap Call FAB -> Voice Call | Enters Voice Call screen with audio enabled, speakerphone on, and timer running. |
| **Outgoing Video Call** | Tap Call FAB -> Video Call | Enters Video Call with remote view, local camera PiP, flip camera, and mic controls. |
| **Simulate Incoming** | Tap Call FAB -> Simulate Incoming | Displays pulsing incoming screen with caller details; Accept/Decline saves to Hive history. |
| **Direct Post Call** | Tap 📞 or 📹 on any feed post | Starts a direct call with that post author. |
| **Call History** | Complete or decline any call | History list updates automatically with color-coded badge, duration, and timestamp. |

