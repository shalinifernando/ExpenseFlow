# ExpenseFlow

A Flutter-based personal expense and bill management application that allows users to manage expenses, bills, payments, and monthly budgets through a simple dashboard.

## 1. Project Setup Instructions

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio
- Android SDK
- VS Code or Android Studio
- Firebase account
- Android emulator or physical Android device

### Installation

1. Clone the repository:

```bash
git clone https://github.com/shalinifernando/ExpenseFlow.git
```

2. Open the project:

```bash
cd ExpenseFlow
```

3. Install Flutter dependencies:

```bash
flutter pub get
```

4. Make sure Firebase is configured for the project.

5. Run the application:

```bash
flutter run
```

The application can be run using an Android emulator or a connected Android device.

### Firebase

The application uses:

- Firebase Authentication
- Cloud Firestore

Firebase is initialized through:

```text
lib/firebase_options.dart
```

---

## 2. Features Implemented

### User Authentication

- User login
- Email and password validation
- Authentication state management
- Forgot password functionality
- Password reset
- Logout

### Expense Management

- Add expenses
- View expenses
- Edit expenses
- Delete expenses
- Expense categories
- Expense dates
- Expense notes
- Search expenses
- Filter expenses by category
- Firebase storage

### Bill Management

- Add bills
- View bills
- Edit bills
- Delete bills
- Set bill due dates
- Set bill categories
- Set bill recurrence
- Mark bills as paid/unpaid
- Identify overdue bills
- Add bill notes

### Budget Management

- Set monthly budget
- Update monthly budget
- View budget progress
- Track spending against the budget
- Display remaining or exceeded budget amount

### Dashboard

- Total spending
- Expense summary
- Paid bills summary
- Recent expenses
- Monthly budget information
- Spending by category
- Navigation to expenses and bills

### Data Visualization

- Spending-by-category chart
- Graphical representation of expense information

### User Interface

- Light mode
- Dark mode
- Material 3 interface
- Form validation
- Loading indicators
- Error handling
- Confirmation dialogs
- Date pickers
- Clean navigation

---

## 3. Technologies / Packages Used

### Technologies

- **Flutter** – Mobile application framework
- **Dart** – Programming language
- **Firebase** – Backend services
- **Cloud Firestore** – Cloud database
- **Firebase Authentication** – User authentication
- **Android Studio** – Android development and emulator
- **Visual Studio Code** – Development environment

### Flutter Packages

| Package | Purpose |
|---|---|
| `firebase_core` | Initializes and connects the application to Firebase |
| `firebase_auth` | Handles user authentication |
| `cloud_firestore` | Stores and retrieves expenses, bills, and budget data |
| `fl_chart` | Creates spending and category charts |
| `uuid` | Generates unique identifiers |
| `cupertino_icons` | Provides Cupertino-style icons |
| `flutter_lints` | Provides Dart and Flutter code-quality checks |

### Main Dependencies

```yaml
cupertino_icons: ^1.0.8
firebase_core: ^4.15.0
cloud_firestore: ^6.10.0
uuid: ^4.6.0
fl_chart: ^1.2.0
firebase_auth: ^6.7.0
```

---

## 4. AI Tools Used

### ChatGPT

ChatGPT was used as a development assistance tool during the development of ExpenseFlow.

It was used to assist with:

- Understanding Flutter and Dart concepts
- Learning Flutter project structure
- Generating and improving code
- Debugging Flutter errors
- Troubleshooting Firebase integration
- Understanding error messages
- Implementing application features
- Improving user interface layouts
- Reviewing and correcting code
- Providing step-by-step development guidance

AI-generated suggestions were reviewed, adapted, and tested during the development process.

The final application was configured and tested by the developer to ensure that the implemented functionality met the project requirements.