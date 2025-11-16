# RoutineUp

O **RoutineUp** é um aplicativo desenvolvido em **Flutter** com backend em **Firebase**, cujo objetivo é ajudar usuários a criarem, acompanharem e manterem hábitos diários.

---

## 🛠️ Tecnologias Utilizadas

- **Flutter** (SDK 3.9+)
- **Dart**
- **Firebase Authentication**
- **Firebase Firestore**
- **intl**
- **cupertino_icons**

---

## Passo a passo para rodar o projeto

### 1) Clone o repositório

```bash
git clone https://github.com/joaolack/Routine_Up.git
cd Routine_Up
```
### 2) Instale as dependências
```bash
flutter pub get
```
### 3) Configuração Firebase
```dart
static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'Axxxxxxxxx',
    appId: '1xxxxxxxxxxxxxxxxxxxxx',
    messagingSenderId: '76274177509',
    projectId: 'routineup-a17c7',
    authDomain: 'routineup-a17c7.firebaseapp.com',
    storageBucket: 'routineup-a17c7.firebasestorage.app',
  );
```
### 4) Rodar o app

```bash
flutter run -d chrome
```
---

## Contato
Desenvolvedor: João Gabriel Lack
Github: [https://github.com/joaolack](https://github.com/joaolack)