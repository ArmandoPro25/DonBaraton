// import 'dart:js_interop';
import 'package:ejercicio1/main.dart';
import 'package:flutter/material.dart';
import 'package:ejercicio1/db_helper.dart';
import 'package:ejercicio1/MailHelper.dart';

class ScreenProductosAdmin extends StatefulWidget {
  @override
  State<ScreenProductosAdmin> createState() => _ScreenProductosAdmin();
}

class _ScreenProductosAdmin extends State<ScreenProductosAdmin> {
  List<Map<String, dynamic>> _allProductos = [];
  bool _isLoading = false;

  void _refreshProductos() async {
    final productos = await SQLHelper.getAllProductos();
    setState(() {
      _allProductos = productos;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshProductos();
  }

  final TextEditingController _productoEditingController =
      TextEditingController();
  final TextEditingController _precioEditingController =
      TextEditingController();
  final TextEditingController _cantidadEditingController =
      TextEditingController();
  final TextEditingController _imagenEditingController =
      TextEditingController();

  int getIntValue() {
    return int.tryParse(_cantidadEditingController.text) ?? 0;
  }

  double getDoubleValue() {
    return double.tryParse(_precioEditingController.text) ?? 0.0;
  }

  Future<void> _addProducto() async {
    await SQLHelper.createProducto(_productoEditingController.text,
        getDoubleValue(), getIntValue(), _imagenEditingController.text);
    _refreshProductos();
  }

  Future<void> _updateProducto(int id) async {
    await SQLHelper.updateProducto(id, _productoEditingController.text,
        getDoubleValue(), getIntValue(), _imagenEditingController.text);
    _refreshProductos();
  }

  Future<void> _deleteProducto(int id) async {
    await SQLHelper.deleteProducto(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Registro eliminado"),
    ));
    _refreshProductos();
  }

  void muestraDatosProductos(int? id) {
    if (id != null) {
      final existingProducto =
          _allProductos.firstWhere((element) => element['id'] == id);
      _productoEditingController.text = existingProducto['nombre_producto'];
      _precioEditingController.text = existingProducto['precio'].toString();
      _cantidadEditingController.text =
          existingProducto['cantidad_producto'].toString();
      _imagenEditingController.text = existingProducto['imagen'];
    } else {
      _productoEditingController.clear();
      _precioEditingController.clear();
      _cantidadEditingController.clear();
      _imagenEditingController.clear();
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _productoEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Nombre del Producto",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _precioEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Precio",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _cantidadEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Cantidad Existencias",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _imagenEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Imagen",
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addProducto();
                  } else {
                    await _updateProducto(id);
                  }
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    id == null ? "Agregar Producto" : "Actualizar Producto",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEAF4),
      appBar: AppBar(
        title: Text("Listado de Productos"),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[900],
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text(
              'Cerrar Sesión',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allProductos.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.all(15),
                child: ListTile(
                  leading: ClipOval(
                    child: Image.network(
                      _allProductos[index]['imagen'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _allProductos[index]['nombre_producto'],
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  subtitle: Text("ID: ${_allProductos[index]['id']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          muestraDatosProductos(_allProductos[index]['id']);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.amberAccent,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteProducto(_allProductos[index]['id']);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => muestraDatosProductos(null),
        child: Icon(Icons.add),
      ),
    );
  }
}

class ScreenProductosVisitante extends StatefulWidget {
  @override
  State<ScreenProductosVisitante> createState() => _ScreenProductosVisitante();
}

class _ScreenProductosVisitante extends State<ScreenProductosVisitante> {
  List<Map<String, dynamic>> _allProductos = [];
  bool _isLoading = true;

  void _refreshProductos() async {
    final productos = await SQLHelper.getAllProductos();
    setState(() {
      _allProductos = productos;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshProductos();
  }

  Future<void> _actualizarCantidadProducto(int id, int cantidadComprada) async {
    final producto = _allProductos.firstWhere((element) => element['id'] == id);
    int nuevaCantidad = producto['cantidad_producto'] - cantidadComprada;
    
    await SQLHelper.updateProducto(
      id,
      producto['nombre_producto'],
      producto['precio'],
      nuevaCantidad,
      producto['imagen'],
    );
    _refreshProductos();
  }

  void muestraDatosProductos(int? id) {
    if (id != null) {
      final existingProducto =
          _allProductos.firstWhere((element) => element['id'] == id);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          int cantidadSeleccionada = 1;

          int max = existingProducto['cantidad_producto'];
          cantidadSeleccionada = (cantidadSeleccionada).clamp(1, max);

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Comprar: ${existingProducto['nombre_producto']}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(existingProducto['imagen'],
                        fit: BoxFit.cover),
                    SizedBox(height: 10),
                    Text('Precio: \$${existingProducto['precio']}'),
                    Text('Existencias: ${existingProducto['cantidad_producto']}'),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cantidad:'),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                
                                if (cantidadSeleccionada > 1) {
                                  setState(() {
                                    cantidadSeleccionada--;
                                  });
                                }
                              },
                            ),
                            SizedBox(
                              width: 40,
                              child: Center(
                                child: Text(
                                  cantidadSeleccionada.toString(),
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                if (cantidadSeleccionada <
                                    existingProducto['cantidad_producto']) {
                                  setState(() {
                                    cantidadSeleccionada++;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cerrar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await SQLHelper.productosCarrito(existingProducto['id'], cantidadSeleccionada);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Productos añadidos al carrito.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    child: Text('Confirmar'),
                  ),
                ],
              );
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEAF4),
      appBar: AppBar(
        title: Text("Listado de Productos"),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[900],
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text(
              'Cerrar Sesión',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _allProductos.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.all(15),
                child: ListTile(
                  leading: ClipOval(
                    child: Image.network(
                      _allProductos[index]['imagen'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      _allProductos[index]['nombre_producto'],
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ID: ${_allProductos[index]['id']}"),
                      Text("Existencias: ${_allProductos[index]['cantidad_producto']}"),
                    ],
                  ),
                  onTap: () {
                    muestraDatosProductos(_allProductos[index]['id']);
                  },
                ),
              ),
            ),
    );
  }
}

class MiCarrito extends StatefulWidget {
  @override
  _MiCarritoState createState() => _MiCarritoState();
}

class _MiCarritoState extends State<MiCarrito> {
  Future<List<Map<String, dynamic>>> _cartItems = SQLHelper.verCarrito();

  void _refreshMiCarrito() {
    setState(() {
      _cartItems = SQLHelper.verCarrito();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi carrito'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _cartItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aún no hay productos'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data![index];
                      var productoId = item['id_producto'];

                      if (productoId == null) {
                        return ListTile(
                          title: Text('Producto no disponible'),
                        );
                      }

                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: SQLHelper.getSingleProducto(productoId),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (productSnapshot.hasData && productSnapshot.data!.isNotEmpty) {
                            var producto = productSnapshot.data!.first;
                            return ListTile(
                              title: Text(producto['nombre_producto']),
                              subtitle: Text('Cantidad: ${item['cantidad_producto']}'),
                            );
                          } else {
                            return ListTile(
                              title: Text('Producto no encontrado'),
                            );
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                var cartItems = await SQLHelper.verCarrito();
                if (cartItems.isNotEmpty) {
                  await MailHelper.send(cartItems);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Compra realizada exitosamente.')),
                  );
                  await SQLHelper.limpiarCarrito();
                  _refreshMiCarrito();
                }
              },
              child: Text('Comprar pedido'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
