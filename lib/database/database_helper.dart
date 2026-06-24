import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shuttlesync.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: 4, // BUMPED TO VERSION 4
      onCreate: _createDB,
      onUpgrade: _onUpgrade, 
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS Users');
      await db.execute('DROP TABLE IF EXISTS Cart');
      await db.execute('DROP TABLE IF EXISTS Products');
      await db.execute('DROP TABLE IF EXISTS Courts');
      await db.execute('DROP TABLE IF EXISTS Bookings');
      await db.execute('DROP TABLE IF EXISTS ContactMessages');
      await db.execute('DROP TABLE IF EXISTS Orders');
      await _createDB(db, newVersion);
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE Orders ADD COLUMN shipping_address TEXT');
      } catch (e) {
        // Ignore if column already exists
      }
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone_number TEXT,
        password_hash TEXT NOT NULL,
        role TEXT NOT NULL,
        win_rate REAL,
        matches_played INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE Cart (
        cart_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Products (
        product_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        sku TEXT UNIQUE,
        category TEXT,
        price REAL NOT NULL,
        stock_quantity INTEGER NOT NULL,
        low_stock_threshold INTEGER,
        image_path TEXT
      )
    ''');

    // ORDERS TABLE NOW INCLUDES SHIPPING ADDRESS
    await db.execute('''
      CREATE TABLE Orders (
        order_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        total_amount REAL NOT NULL,
        status TEXT NOT NULL, 
        order_date TEXT NOT NULL,
        shipping_address TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Courts (
        court_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        surface_type TEXT,
        hourly_rate REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE Bookings (
        booking_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        court_id INTEGER NOT NULL,
        booking_date TEXT NOT NULL,      
        start_time TEXT NOT NULL,        
        duration_minutes INTEGER NOT NULL,
        status TEXT NOT NULL            
      )
    ''');

    await db.execute('''
      CREATE TABLE ContactMessages (
        message_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        message TEXT,
        date_sent TEXT
      )
    ''');

    // --- YOUR DEFAULT ADMIN ACCOUNT ---
    await db.insert('Users', {
      'full_name': 'Master Admin',
      'email': 'admin@shuttlesync.com',
      'phone_number': '555-0000',
      'password_hash': 'admin123', 
      'role': 'admin',
      'win_rate': 100.0,
      'matches_played': 999
    });
  }

  // --- STANDARD FUNCTIONS ---
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('Users', row);
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query('Users', where: 'email = ? AND password_hash = ?', whereArgs: [email, password]);
    return results.isNotEmpty ? results.first : null; 
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    Database db = await instance.database;
    return await db.query('Products');
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    Database db = await instance.database;
    return await db.insert('Products', product);
  }

  Future<int> deleteProduct(int productId) async {
    Database db = await instance.database;
    return await db.delete('Products', where: 'product_id = ?', whereArgs: [productId]);
  }

  // --- CART FUNCTIONS ---
  Future<List<Map<String, dynamic>>> getCartItems(int userId) async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT Cart.cart_id, Cart.quantity, Products.product_id, Products.name, Products.description, Products.price, Products.sku, Products.category, Products.image_path
      FROM Cart INNER JOIN Products ON Cart.product_id = Products.product_id WHERE Cart.user_id = ?
    ''', [userId]);
  }

  Future<int> addToCart(int userId, int productId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> existing = await db.query('Cart', where: 'user_id = ? AND product_id = ?', whereArgs: [userId, productId]);
    if (existing.isNotEmpty) {
      return await db.update('Cart', {'quantity': existing.first['quantity'] + 1}, where: 'cart_id = ?', whereArgs: [existing.first['cart_id']]);
    } else {
      return await db.insert('Cart', {'user_id': userId, 'product_id': productId, 'quantity': 1});
    }
  }

  Future<int> updateCartQuantity(int cartId, int quantity) async {
    Database db = await instance.database;
    return await db.update('Cart', {'quantity': quantity}, where: 'cart_id = ?', whereArgs: [cartId]);
  }

  Future<int> removeFromCart(int cartId) async {
    Database db = await instance.database;
    return await db.delete('Cart', where: 'cart_id = ?', whereArgs: [cartId]);
  }

  Future<int> clearCart(int userId) async {
    Database db = await instance.database;
    return await db.delete('Cart', where: 'user_id = ?', whereArgs: [userId]);
  }

  // --- ORDERS FUNCTIONS ---
  Future<int> insertOrder(Map<String, dynamic> orderData) async {
    Database db = await instance.database;
    return await db.insert('Orders', orderData);
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT Orders.*, Users.full_name 
      FROM Orders 
      INNER JOIN Users ON Orders.user_id = Users.user_id
      ORDER BY order_id DESC
    ''');
  }

  Future<int> updateOrderStatus(int orderId, String status) async {
    Database db = await instance.database;
    return await db.update('Orders', {'status': status}, where: 'order_id = ?', whereArgs: [orderId]);
  }

  // --- BOOKING FUNCTIONS ---
  Future<List<Map<String, dynamic>>> getBookingsByDate(String date) async {
    Database db = await instance.database;
    return await db.query('Bookings', where: 'booking_date = ?', whereArgs: [date]);
  }

  Future<int> insertBooking(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('Bookings', row);
  }

  Future<int> updateBookingStatus(int bookingId, String status) async {
    Database db = await instance.database;
    return await db.update('Bookings', {'status': status}, where: 'booking_id = ?', whereArgs: [bookingId]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // --- USER SETTINGS FUNCTIONS ---
  Future<int> updateUser(int userId, String fullName, String email, String password) async {
    Database db = await instance.database;
    return await db.update(
      'Users',
      {
        'full_name': fullName,
        'email': email,
        'password_hash': password, 
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // --- CONTACT MESSAGE FUNCTIONS ---
  Future<int> insertContactMessage(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('ContactMessages', row);
  }
  // --- COURT AVAILABILITY FUNCTION ---
  Future<bool> isSlotAvailable(int courtId, String date, String time) async {
    Database db = await instance.database;
    List<Map> result = await db.query(
      'Bookings',
      where: 'court_id = ? AND booking_date = ? AND start_time = ? AND status != ?',
      whereArgs: [courtId, date, time, 'CANCELLED'],
    );
    return result.isEmpty; 
  }
  // --- ANALYTICS FUNCTIONS ---
  Future<Map<String, dynamic>> getAnalyticsData() async {
    Database db = await instance.database;
    
    // 1. Calculate total revenue only from PAID orders
    var revResult = await db.rawQuery("SELECT SUM(total_amount) as total FROM Orders WHERE status = 'PAID'");
    double revenue = (revResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // 2. Count total orders made
    var orderCountResult = await db.rawQuery("SELECT COUNT(*) as count FROM Orders");
    int orderCount = Sqflite.firstIntValue(orderCountResult) ?? 0;

    // 3. Count total registered players
    var playerResult = await db.rawQuery("SELECT COUNT(*) as count FROM Users WHERE role != 'admin'");
    int playerCount = Sqflite.firstIntValue(playerResult) ?? 0;

    return {
      'revenue': revenue,
      'orders': orderCount,
      'players': playerCount,
    };
  }
}