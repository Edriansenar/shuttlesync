import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  // 1. Create a Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // 2. Open the database connection
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // If it doesn't exist, initialize it
    _database = await _initDB('shuttlesync.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // 3. Define your schema here
  Future _createDB(Database db, int version) async {
    // Create the Users table
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
        user_id INTEGER,
        product_id INTEGER,
        quantity INTEGER
      )
    ''');

    // Create the Products table
    await db.execute('''
      CREATE TABLE Products (
        product_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        sku TEXT UNIQUE,
        category TEXT,
        price REAL NOT NULL,
        stock_quantity INTEGER NOT NULL,
        low_stock_threshold INTEGER
      )
    ''');

    // Create the Courts table
    await db.execute('''
      CREATE TABLE Courts (
        court_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        surface_type TEXT,
        hourly_rate REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');
    
    // --- SPRINT 2: BOOKINGS TABLE ---
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
      CREATE TABLE Bookings (
        booking_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        court_id INTEGER,
        booking_date TEXT,
        start_time TEXT,
        duration_minutes INTEGER,
        status TEXT
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

    // --- SPRINT 1: SEED DEFAULT ADMIN ACCOUNT ---
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

  // --- CRUD Operations --- //

  // Insert a new user (Sign Up)
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('Users', row);
  }

  // Fetch all products for the shop
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    Database db = await instance.database;
    return await db.query('Products');
  }

  // Login User Check
  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results = await db.query(
      'Users',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email, password],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null; 
  }

  // --- SPRINT 2: BOOKING LOGIC & CONFLICT RESOLUTION --- //

  // Checks if a court is already booked for a specific date and time
  Future<bool> isSlotAvailable(int courtId, String date, String time) async {
    Database db = await instance.database;
    List<Map> result = await db.query(
      'Bookings',
      where: 'court_id = ? AND booking_date = ? AND start_time = ? AND status != ?',
      whereArgs: [courtId, date, time, 'CANCELLED'],
    );
    return result.isEmpty; // Returns True if the slot is empty!
  }

  // Inserts the new booking into the database
  Future<int> insertBooking(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('Bookings', row);
  }

  // Close the database safely
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // --- SPRINT 2: CART FUNCTIONS ---
  
  Future<List<Map<String, dynamic>>> getCartItems(int userId) async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT Cart.cart_id, Cart.quantity, Products.product_id, Products.name, Products.description, Products.price, Products.sku, Products.category
      FROM Cart
      INNER JOIN Products ON Cart.product_id = Products.product_id
      WHERE Cart.user_id = ?
    ''', [userId]);
  }

  Future<int> addToCart(int userId, int productId) async {
    Database db = await instance.database;
    // Check if item is already in the cart
    List<Map<String, dynamic>> existing = await db.query('Cart', where: 'user_id = ? AND product_id = ?', whereArgs: [userId, productId]);
    if (existing.isNotEmpty) {
      int newQty = existing.first['quantity'] + 1;
      return await db.update('Cart', {'quantity': newQty}, where: 'cart_id = ?', whereArgs: [existing.first['cart_id']]);
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
  // --- SPRINT 2: UPDATE USER CREDENTIALS ---
  Future<int> updateUser(int userId, String fullName, String email, String password) async {
    Database db = await instance.database;
    return await db.update(
      'Users',
      {
        'full_name': fullName,
        'email': email,
        'password': password, // Note: In a real app, always hash passwords!
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
  // --- SPRINT 2: CONTACT SUPPORT ---
  Future<int> insertContactMessage(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('ContactMessages', row);
  }

  // --- SPRINT 2: ADMIN MANAGEMENT ---
  
  // Add a new product from the Admin Dashboard
  Future<int> insertProduct(Map<String, dynamic> product) async {
    Database db = await instance.database;
    return await db.insert('Products', product);
  }

  // Get all bookings for a specific date (Format: YYYY-MM-DD)
  Future<List<Map<String, dynamic>>> getBookingsByDate(String date) async {
    Database db = await instance.database;
    return await db.query('Bookings', where: 'booking_date = ?', whereArgs: [date]);
  }

  // Cancel a booking or block a court for maintenance
  Future<int> updateBookingStatus(int bookingId, String status) async {
    Database db = await instance.database;
    return await db.update('Bookings', {'status': status}, where: 'booking_id = ?', whereArgs: [bookingId]);
  }
  // --- SPRINT 2: ADMIN INVENTORY MANAGEMENT ---
  Future<int> deleteProduct(int productId) async {
    Database db = await instance.database;
    return await db.delete('Products', where: 'product_id = ?', whereArgs: [productId]);
  }

  Future<int> updateProductStock(int productId, int newStock) async {
    Database db = await instance.database;
    return await db.update('Products', {'stock_quantity': newStock}, where: 'product_id = ?', whereArgs: [productId]);
  }
}