import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
final uuid = Uuid();

void main() {
  runApp(const WalletMateApp());
}

// ---------- Models ----------
enum Category { food, clothing, loans, transport, entertainment, utilities, others }

extension CategoryExt on Category {
  String get name {
    switch (this) {
      case Category.food:
        return 'Food';
      case Category.clothing:
        return 'Clothing';
      case Category.loans:
        return 'Loans';
      case Category.transport:
        return 'Transport';
      case Category.entertainment:
        return 'Entertainment';
      case Category.utilities:
        return 'Utilities';
      default:
        return 'Others';
    }
  }
}

class Contact {
  String id;
  String name;
  String phone;

  Contact({required this.id, required this.name, required this.phone});
}

class TransactionItem {
  String id;
  String contactId;
  double amount;
  DateTime date;
  bool incoming;
  String note;
  Category category; 

  TransactionItem({
    required this.id,
    required this.contactId,
    required this.amount,
    required this.date,
    required this.incoming,
    this.note = '',
    required this.category, 
  });
}

// ---------- Simple In-memory State Manager ----------
class WalletModel extends ChangeNotifier {
  final List<Contact> _contacts = [];
  final List<TransactionItem> _transactions = [];

  List<Contact> get contacts => List.unmodifiable(_contacts);
  List<TransactionItem> get transactions => List.unmodifiable(_transactions);

  void addContact(Contact c) {
    _contacts.add(c);
    notifyListeners();
  }

  void editContact(String id, Contact updated) {
    final i = _contacts.indexWhere((c) => c.id == id);
    if (i != -1) _contacts[i] = updated;
    notifyListeners();
  }

  void deleteContact(String id) {
    _contacts.removeWhere((c) => c.id == id);
    _transactions.removeWhere((t) => t.contactId == id);
    notifyListeners();
  }

  void addTransaction(TransactionItem t) {
    _transactions.add(t);
    notifyListeners();
  }

  void editTransaction(String id, TransactionItem updated) {
    final i = _transactions.indexWhere((t) => t.id == id);
    if (i != -1) _transactions[i] = updated;
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  double get balance {
    double b = 0;
    for (var t in _transactions) {
      b += t.incoming ? t.amount : -t.amount;
    }
    return b;
  }
}

final WalletModel walletModel = WalletModel();

// ---------- The App with Theme Toggle ----------
class WalletMateApp extends StatefulWidget {
  const WalletMateApp({super.key});

  @override
  State<WalletMateApp> createState() => _WalletMateAppState();
}

class _WalletMateAppState extends State<WalletMateApp> {
  bool isDarkTheme = false;

  void toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WalletMate',
      debugShowCheckedModeBanner: false, 
      theme: isDarkTheme ? ThemeData.dark() : ThemeData(primarySwatch: Colors.teal),
      home: AppRoot(toggleTheme: toggleTheme, isDarkTheme: isDarkTheme),
      routes: {
        '/contacts': (_) => ContactsScreen(),
        '/add_contact': (_) => AddEditContactScreen(),
        '/transactions': (_) => TransactionsScreen(),
        '/add_transaction': (_) => AddTransactionScreen(),
        '/categories': (_) => CategoriesScreen(),
        '/reports': (_) => ReportsScreen(),
        '/settings': (_) => SettingsScreen(toggleTheme: toggleTheme, isDarkTheme: isDarkTheme),
      },
    );
  }
}

// ---------- App Root with Drawer (Home Screen) ----------
class AppRoot extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkTheme;
  const AppRoot({super.key, required this.toggleTheme, required this.isDarkTheme});

  @override
  _AppRootState createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    TransactionsScreen(),
    ContactsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WalletMate')),
      drawer: AppDrawer(
        toggleTheme: widget.toggleTheme,
        isDarkTheme: widget.isDarkTheme,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tracker'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Contacts'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 2) {
            Navigator.pushNamed(context, '/add_contact');
          } else {
            Navigator.pushNamed(context, '/add_transaction');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------- Drawer Widget (Home Screen requirement) ----------
class AppDrawer extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkTheme;
  const AppDrawer({super.key, required this.toggleTheme, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.teal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 28, child: Icon(Icons.account_balance_wallet)),
                const SizedBox(height: 12),
                const Text('WalletMate', style: TextStyle(color: Colors.white, fontSize: 20)),
                const Text('Your finance companion', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(leading: const Icon(Icons.home), title: const Text('Home'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.list), title: const Text('Transactions'), onTap: () => Navigator.pushNamed(context, '/transactions')),
          ListTile(leading: const Icon(Icons.people), title: const Text('Contacts'), onTap: () => Navigator.pushNamed(context, '/contacts')),
          // Removed Categories from Drawer
          ListTile(leading: const Icon(Icons.bar_chart), title: const Text('Reports'), onTap: () => Navigator.pushNamed(context, '/reports')),
          const Divider(),
          ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () => Navigator.pushNamed(context, '/settings')),
          SwitchListTile(
            title: const Text('Dark Theme'),
            value: isDarkTheme,
            onChanged: (_) => toggleTheme(),
            secondary: Icon(isDarkTheme ? Icons.dark_mode : Icons.light_mode),
          ),
        ],
      ),
    );
  }
}

// ---------- Home Screen (Dashboard) ----------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              leading: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 0.8 - 0.4, 
                    child: child,
                  );
                },
                child: const Icon(Icons.account_balance_wallet, size: 36),
              ),
              title: Row(
                children: [
                  const Text('Current Balance'),
                  const SizedBox(width: 8),
                ],
              ),
              trailing: Text('₹ ${walletModel.balance.toStringAsFixed(2)}'),
            ),
          ),
          const SizedBox(height: 12),
          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTransactionScreen(prefilledContact: null),
                    settings: RouteSettings(arguments: true), // incoming = true
                  ),
                ),
                icon: const Icon(Icons.call_received),
                label: const Text('Add Expense'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTransactionScreen(prefilledContact: null),
                    settings: RouteSettings(arguments: false), // incoming = false
                  ),
                ),
                icon: const Icon(Icons.send),
                label: const Text('Add Income'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
          const Expanded(
            child: TransactionsListView(),
          ),
        ],
      ),
    );
  }
}

// ---------- Transactions List View Widget (reused) ----------
class TransactionsListView extends StatefulWidget {
  const TransactionsListView({super.key});

  @override
  _TransactionsListViewState createState() => _TransactionsListViewState();
}

class _TransactionsListViewState extends State<TransactionsListView> {
  @override
  Widget build(BuildContext context) {
    final txs = walletModel.transactions.reversed.toList();
    if (txs.isEmpty) {
      return const Center(child: Text('No transactions yet'));
    }
    return ListView.builder(
      itemCount: txs.length,
      itemBuilder: (context, index) {
        final t = txs[index];
        final contact = walletModel.contacts.firstWhere((c) => c.id == t.contactId, orElse: () => Contact(id: 'na', name: 'Unknown', phone: ''));
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Icon(t.incoming ? Icons.arrow_downward : Icons.arrow_upward)),
            title: Text(contact.name),
            subtitle: Text(DateFormat.yMMMd().format(t.date)),
            trailing: Text('${t.incoming ? '+' : '-'}₹${t.amount.toStringAsFixed(2)}'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionDetailsScreen(transactionId: t.id))),
          ),
        );
      },
    );
  }
}

// ---------- Contacts Screen (List + CRUD) ----------
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  Widget build(BuildContext context) {
    final contacts = walletModel.contacts;
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: contacts.isEmpty
          ? const Center(child: Text('No contacts yet. Tap + to add.'))
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, i) {
                final c = contacts[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(c.name.isNotEmpty ? c.name[0] : '?')),
                    title: Text(c.name),
                    subtitle: Text(c.phone),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditContactScreen(contact: c)));
                        if (v == 'delete') {
                          walletModel.deleteContact(c.id);
                          setState(() {});
                        }
                      },
                      itemBuilder: (_) => [const PopupMenuItem(value: 'edit', child: Text('Edit')), const PopupMenuItem(value: 'delete', child: Text('Delete'))],
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactDetailScreen(contact: c))),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.pushNamed(context, '/add_contact'), child: const Icon(Icons.add)),
    );
  }
}

// ---------- Add / Edit Contact Screen (User input) ----------
class AddEditContactScreen extends StatefulWidget {
  final Contact? contact;
  const AddEditContactScreen({super.key, this.contact});
  @override
  _AddEditContactScreenState createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _phone;

  @override
  void initState() {
    super.initState();
    _name = widget.contact?.name ?? '';
    _phone = widget.contact?.phone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.contact != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Contact' : 'Add Contact')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                onSaved: (v) => _name = v!.trim(),
              ),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Phone (reference)'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                onSaved: (v) => _phone = v!.trim(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (isEdit) {
                      walletModel.editContact(widget.contact!.id, Contact(id: widget.contact!.id, name: _name, phone: _phone));
                    } else {
                      final id = uuid.v4();
                      walletModel.addContact(Contact(id: id, name: _name, phone: _phone));
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(isEdit ? 'Save' : 'Add Contact'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Contact Detail Screen ----------
class ContactDetailScreen extends StatelessWidget {
  final Contact contact;
  const ContactDetailScreen({super.key, required this.contact});
  @override
  Widget build(BuildContext context) {
    final related = walletModel.transactions.where((t) => t.contactId == contact.id).toList();
    return Scaffold(
      appBar: AppBar(title: Text(contact.name)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${contact.phone}'),
            const SizedBox(height: 12),
            Text('Transactions', style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              child: ListView.builder(
                itemCount: related.length,
                itemBuilder: (context, i) {
                  final t = related[i];
                  return ListTile(
                    title: Text('${t.incoming ? 'Received' : 'Paid'} ₹${t.amount.toStringAsFixed(2)}'),
                    subtitle: Text(DateFormat.yMMMd().format(t.date)),
                    trailing: Text(t.note),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen(prefilledContact: contact))),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------- Transactions Screen (Finance Tracker) ----------
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _showIncoming = true;
  bool _showOutgoing = true;
  final Set<Category> _selectedCategories = Category.values.toSet();

  @override
  Widget build(BuildContext context) {
    var txs = walletModel.transactions;
    // Filter by in/out
    if (!(_showIncoming && _showOutgoing)) {
      txs = txs.where((t) => (_showIncoming && t.incoming) || (_showOutgoing && !t.incoming)).toList();
    }
    txs = txs.where((t) => _selectedCategories.contains(t.category)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Filter')),
                    Row(children: [const Text('In'), Switch(value: _showIncoming, onChanged: (v) => setState(() => _showIncoming = v))]),
                    Row(children: [const Text('Out'), Switch(value: _showOutgoing, onChanged: (v) => setState(() => _showOutgoing = v))]),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: Category.values.map((cat) {
                    final selected = _selectedCategories.contains(cat);
                    return FilterChip(
                      label: Text(cat.name),
                      selected: selected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedCategories.add(cat);
                          } else {
                            _selectedCategories.remove(cat);
                          }
                          // Prevent empty selection
                          if (_selectedCategories.isEmpty) {
                            _selectedCategories.add(cat);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: txs.isEmpty
                ? const Center(child: Text('No transactions'))
                : ListView.builder(
                    itemCount: txs.length,
                    itemBuilder: (context, i) {
                      final t = txs[i];
                      final c = walletModel.contacts.firstWhere(
                        (c) => c.id == t.contactId,
                        orElse: () => Contact(id: 'na', name: 'Unknown', phone: ''),
                      );
                      return Dismissible(
                        key: Key(t.id),
                        background: Container(color: Colors.red, child: const Icon(Icons.delete, color: Colors.white)),
                        onDismissed: (_) {
                          walletModel.deleteTransaction(t.id);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
                        },
                        child: ListTile(
                          leading: CircleAvatar(child: Icon(t.incoming ? Icons.arrow_downward : Icons.arrow_upward)),
                          title: Text(c.name),
                          subtitle: Text('${t.category.name} • ${DateFormat.yMMMd().format(t.date)}'),
                          trailing: Text('${t.incoming ? '+' : '-'}₹${t.amount.toStringAsFixed(2)}'),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionDetailsScreen(transactionId: t.id))),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.pushNamed(context, '/add_transaction'), child: const Icon(Icons.add)),
    );
  }
}

// ---------- Add Transaction Screen (user input; choose existing contact) ----------
class AddTransactionScreen extends StatefulWidget {
  final Contact? prefilledContact;
  const AddTransactionScreen({super.key, this.prefilledContact});
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _contactId;
  double _amount = 0;
  DateTime _date = DateTime.now();
  bool _incoming = false;
  String _note = '';
  Category _category = Category.others; 

  @override
  void initState() {
    super.initState();
    _contactId = widget.prefilledContact?.id;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is bool) {
      setState(() {
        _incoming = arg;
      });
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d != null) setState(() => _date = d);
  }

  Future<void> _showInsufficientBalanceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Balance'),
        content: const Text('You do not have enough balance to complete this transaction.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = walletModel.contacts;
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _contactId,
                items: contacts.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _contactId = v),
                validator: (v) => v == null || v.isEmpty ? 'Select contact' : null,
                decoration: const InputDecoration(labelText: 'Contact'),
              ),
              DropdownButtonFormField<Category>(
                value: _category,
                items: Category.values.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name))).toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val <= 0) return 'Enter a positive amount';
                  return null;
                },
                onSaved: (v) => _amount = double.parse(v!),
              ),
              ListTile(
                title: Text('Date: ${DateFormat.yMMMd().format(_date)}'),
                trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
              ),
              SwitchListTile(title: const Text('Incoming (Received)?'), value: _incoming, onChanged: (v) => setState(() => _incoming = v)),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                onSaved: (v) => _note = v ?? '',
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (!_incoming && _amount > walletModel.balance) {
                      await _showInsufficientBalanceDialog();
                      return;
                    }
                    final id = uuid.v4();
                    walletModel.addTransaction(TransactionItem(
                      id: id,
                      contactId: _contactId!,
                      amount: _amount,
                      date: _date,
                      incoming: _incoming,
                      note: _note,
                      category: _category,
                    ));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction added')));
                  }
                },
                child: const Text('Save Transaction'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Transaction Details (Edit/Delete) ----------
class TransactionDetailsScreen extends StatefulWidget {
  final String transactionId;
  const TransactionDetailsScreen({super.key, required this.transactionId});
  @override
  _TransactionDetailsScreenState createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late TransactionItem tx;
  bool _editing = false;
  final _editKey = GlobalKey<FormState>();
  late double _amount;
  late DateTime _date;
  late bool _incoming;
  late String _note;

  @override
  void initState() {
    super.initState();
    tx = walletModel.transactions.firstWhere((t) => t.id == widget.transactionId);
    _amount = tx.amount;
    _date = tx.date;
    _incoming = tx.incoming;
    _note = tx.note;
  }

  @override
  Widget build(BuildContext context) {
    final contact = walletModel.contacts.firstWhere((c) => c.id == tx.contactId, orElse: () => Contact(id: 'na', name: 'Unknown', phone: ''));
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _editing ? Form(
          key: _editKey,
          child: ListView(
            children: [
              Text('Contact: ${contact.name}'),
              TextFormField(initialValue: _amount.toString(), decoration: const InputDecoration(labelText: 'Amount'), keyboardType: const TextInputType.numberWithOptions(decimal: true), onSaved: (v) => _amount = double.parse(v!)),
              ListTile(title: Text('Date: ${DateFormat.yMMMd().format(_date)}'), trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (d != null) setState(() => _date = d);
              })),
              SwitchListTile(title: const Text('Incoming?'), value: _incoming, onChanged: (v) => setState(() => _incoming = v)),
              TextFormField(initialValue: _note, decoration: const InputDecoration(labelText: 'Note'), onSaved: (v) => _note = v ?? ''),
              ElevatedButton(onPressed: () {
                _editKey.currentState!.save();
                walletModel.editTransaction(tx.id, TransactionItem(id: tx.id, contactId: tx.contactId, amount: _amount, date: _date, incoming: _incoming, note: _note, category: Category.others));
                setState(() { _editing = false; tx = walletModel.transactions.firstWhere((t) => t.id == tx.id); });
              }, child: const Text('Save'))
            ],
          ),
        ) : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(leading: CircleAvatar(child: Text(contact.name[0])), title: Text(contact.name)),
            const SizedBox(height: 8),
            Text('${tx.incoming ? 'Received' : 'Paid'}: ₹${tx.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
            Text('Date: ${DateFormat.yMMMd().format(tx.date)}'),
            Text('Note: ${tx.note}'),
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton.icon(icon: const Icon(Icons.edit), label: const Text('Edit'), onPressed: () => setState(() => _editing = true)),
              const SizedBox(width: 12),
              ElevatedButton.icon(onPressed: () {
                walletModel.deleteTransaction(tx.id);
                Navigator.pop(context);
              }, icon: const Icon(Icons.delete), label: const Text('Delete'))
            ])
          ],
        ),
      ),
    );
  }
}

// ---------- Categories Screen (simple CRUD placeholder) ----------
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Categories')), body: ListView(children: Category.values.map((c) => ListTile(title: Text(c.name))).toList()));
  }
}

// ---------- Reports Screen (placeholder) ----------
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = walletModel.contacts;
    final txs = walletModel.transactions;
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          const Text('Transactions Table'),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(columns: const [DataColumn(label: Text('Contact')), DataColumn(label: Text('Type')), DataColumn(label: Text('Amt')), DataColumn(label: Text('Date'))], rows: txs.map((t) {
                final c = contacts.firstWhere((c) => c.id == t.contactId, orElse: () => Contact(id: 'na', name: 'Unknown', phone: ''));
                return DataRow(cells: [DataCell(Text(c.name)), DataCell(Text(t.incoming ? 'In' : 'Out')), DataCell(Text('₹${t.amount.toStringAsFixed(2)}')), DataCell(Text(DateFormat.yMMMd().format(t.date)))]);
              }).toList()),
            ),
          )
        ]),
      ),
    );
  }
}

// ---------- Settings ----------
class SettingsScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkTheme;
  const SettingsScreen({super.key, required this.toggleTheme, required this.isDarkTheme});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(title: const Text('Notifications'), value: _notifications, onChanged: (v) => setState(() => _notifications = v)),
            SwitchListTile(
              title: const Text('Dark Theme'),
              value: widget.isDarkTheme,
              onChanged: (_) => widget.toggleTheme(),
              secondary: Icon(widget.isDarkTheme ? Icons.dark_mode : Icons.light_mode),
            ),
            ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved!'))), child: const Text('Save'))
          ],
        ),
      ),
    );
  }
}
