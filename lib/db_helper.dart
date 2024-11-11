import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {

  static String? userEmail;

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE user_app(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    user_name TEXT,
    pass TEXT,
    descripcion TEXT,
    correo TEXT,
    permiso TEXT,
    createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");

    await database.execute("""CREATE TABLE producto_app(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    nombre_producto TEXT,
    precio DOUBLE,
    cantidad_producto INTEGER,
    imagen TEXT,
    createdAT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");

    await database.execute("""CREATE TABLE carrito_app(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    id_producto INTEGER,
    cantidad_producto INTEGER,
    FOREIGN KEY (id_producto) REFERENCES producto_app (id) ON DELETE CASCADE
    )""");

  }

  //
  //              CREAR BASE DE DATOS
  static Future<sql.Database> db() async {
    return sql.openDatabase("Prueba2.db", version: 1, //Ya existe prueba 0, 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  //
  //              CRUD USUARIOS
  static Future<int> createUser(String user, String? pass, String description,
      String? email, String permiso) async {
    final db = await SQLHelper.db();
    final user_app = {
      'user_name': user,
      'pass': pass,
      'descripcion': description,
      'correo': email,
      'permiso': permiso //Verificar que se incluya el permiso
    };
    final id = await db.insert('user_app', user_app,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllUser() async {
    final db = await SQLHelper.db();
    return db.query('user_app', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getSingleUser(int id) async {
    final db = await SQLHelper.db();
    return db.query('user_app', where: "id=?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateUser(int id, String nombre, String? pass,
      String description, String? email, String permiso) async {
    final db = await SQLHelper.db();
    final user = {
      'user_name': nombre,
      'pass': pass,
      'descripcion': description,
      'correo': email,
      'permiso': permiso, //Validar el permiso
      'createdAT': DateTime.now().toString()
    };
    return await db.update('user_app', user, where: "id = ?", whereArgs: [id]);
  }

  static Future<void> deleteUser(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('user_app', where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print("Error al eliminar el registro: $e");
    }
  }

  //
  //              VALIDACIÓN LOGIN
  Future<bool> login_user(String nombre, String pass) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> user = await db.query('user_app',
        where: 'user_name = ? AND pass = ? AND permiso = "Administrador"',
        whereArgs: [nombre, pass]);

    if (user.isEmpty) {
      return false;
    } else {
      userEmail = user.first['correo'];
      return true;
    }
  }

  Future<bool> login_user_visitante(String nombre, String pass) async {
    final db = await SQLHelper.db();
    List<Map<String, dynamic>> user = await db.query('user_app',
        where: 'user_name = ? AND pass = ? AND permiso = "Visitante"',
        whereArgs: [nombre, pass]);

    if (user.isEmpty) {
      return false;
    } else {
//   OBTENER CORREO DEL USUARIO QUE INICIA SESION
      userEmail = user.first['correo'];
      return true;
    }
  }

  //
  //              CRUD PRODUCTOS
  static Future<int> createProducto(
      String? producto, double? precio, int cantidad, String? imagen) async {
    final db = await SQLHelper.db();
    final producto_app = {
      'nombre_producto': producto,
      'precio': precio,
      'cantidad_producto': cantidad,
      'imagen': imagen
    };
    final id = await db.insert('producto_app', producto_app,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllProductos() async {
    final db = await SQLHelper.db();
    return db.query('producto_app', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getSingleProducto(int id) async {
    final db = await SQLHelper.db();
    return db.query('producto_app', where: "id=?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateProducto(int id, String? producto, double? precio,
      int cantidad, String? imagen) async {
    final db = await SQLHelper.db();
    final producto_app = {
      'nombre_producto': producto,
      'precio': precio,
      'cantidad_producto': cantidad,
      'imagen': imagen,
      'createdAT': DateTime.now().toString()
    };
    return await db
        .update('producto_app', producto_app, where: "id = ?", whereArgs: [id]);
  }

  static Future<void> deleteProducto(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('producto_app', where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print("Error al eliminar el producto: $e");
    }
  }

  static Future<String?> obtenerEmail(String usuario) async {
    final db = await SQLHelper.db();
  
    List<Map<String, dynamic>> user = await db.query(
      'user_app',
      where: 'user_name = ?',
      whereArgs: [usuario],
      limit: 1
      );

    if (user.isEmpty) {
      return null;
    } else {
      return user.first['correo'];
    }
  }

  static Future<int> productosCarrito(int id_producto, int cantidad_producto) async {
  final db = await SQLHelper.db();

  final miCarrito = {
    'id_producto': id_producto,
    'cantidad_producto': cantidad_producto,
  };
  final id = await db.insert('carrito_app', miCarrito);

  await db.rawUpdate("""
    UPDATE producto_app 
    SET cantidad_producto = cantidad_producto - ? 
    WHERE id = ?
  """, [cantidad_producto, id_producto]);

  return id;
  }

  static Future<List<Map<String, dynamic>>> verCarrito() async {
    final db = await SQLHelper.db();
    return db.query('carrito_app', orderBy: 'id');
  }

  static Future<void> limpiarCarrito() async {
    final db = await SQLHelper.db();
    await db.delete('carrito_app');
  }  

}
