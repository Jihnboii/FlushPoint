# FlushPoint

FlushPoint is a Flutter application that helps users find and add public toilets on a map. The app uses Google Maps for displaying locations and Firebase for backend services.

## Features

- Display public toilets on a Google Map.
- Add new toilets with details such as name, address, cleanliness, facilities, and notes.
- View details of each toilet.
- User authentication with Firebase.
- Profile management.

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK: Included with Flutter
- Android Studio: [Install Android Studio](https://developer.android.com/studio)
- Firebase account: [Create Firebase Project](https://firebase.google.com/)

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/Jihnboii/flutter_setup.git
   cd flutter_setup
   ```

2. Install dependencies:
   ```sh
   flutter pub get
   ```

3. Set up Firebase:
    - Follow the instructions to add Firebase to your Flutter app: [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup)
    - Add your `google-services.json` file to `android/app`.

4. Add your Google Maps API key:
    - Replace the value of `GOOGLE_API_KEY` in `android/gradle.properties` with your actual API key.
    - Add the API key to `android/app/src/main/AndroidManifest.xml`:
      ```xml
      <meta-data
          android:name="com.google.android.geo.API_KEY"
          android:value="YOUR_API_KEY_HERE" />
      ```

### Running the App

1. Connect your device or start an emulator.
2. Run the app:
   ```sh
   flutter run
   ```

## Usage

- Use the search bar to find toilets.
- Tap the add button to add a new toilet.
- View details of a toilet by tapping on it in the list.
- Manage your profile and view your favorite toilets.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```