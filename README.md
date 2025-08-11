# WalletMate

WalletMate is a simple Flutter app for tracking personal finances, managing contacts, and categorizing transactions.  
It helps you keep an eye on your balance, record payments, and analyze your spending.

## Features

- **Dashboard:** View your current balance and recent transactions.
- **Quick Actions:** Easily record received or sent payments.
- **Contacts:** Add, edit, and delete contacts for your transactions.
- **Transactions:** Track all payments, filter by type (in/out) and category.
- **Categories:** Assign categories to transactions for better organization.
- **Reports:** View a simple table of all transactions.
- **Theme Toggle:** Switch between light and dark mode.
- **Settings:** Manage notification and theme preferences.

## Getting Started

1. **Install Flutter:**  
   [Flutter installation guide](https://docs.flutter.dev/get-started/install)

2. **Clone this repository:**  
   ```sh
   git clone <your-repo-url>
   cd wallet_mate
   ```

3. **Install dependencies:**  
   ```sh
   flutter pub get
   ```

4. **Run the app:**  
   ```sh
   flutter run
   ```

## Project Structure

- `lib/main.dart` — Main app logic, UI, and state management.
- Models: `Contact`, `TransactionItem`, `Category`
- Screens: Home, Contacts, Transactions, Add/Edit, Reports, Settings

## Notes

- All data is stored in memory (no database or persistence).
- This app is for demonstration and learning purposes.

## License
