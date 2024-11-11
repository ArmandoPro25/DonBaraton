import 'package:ejercicio1/main.dart';
import 'package:flutter/material.dart';
import 'package:ejercicio1/db_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  List<Map<String, dynamic>> _allUser = [];
  bool _isLoading = false;

  void _refreshUser() async {
    final user = await SQLHelper.getAllUser();
    setState(() {
      _allUser = user;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  final TextEditingController _nombreEditingController = TextEditingController();
  final TextEditingController _passEditingController = TextEditingController();
  final TextEditingController _descripcionEditingController = TextEditingController();
  final TextEditingController _correoEditingController = TextEditingController();
  String _selectedPermiso = 'Visitante';

  Future<void> _addUser() async {
    await SQLHelper.createUser(
        _nombreEditingController.text,
        _passEditingController.text,
        _descripcionEditingController.text,
        _correoEditingController.text,
        _selectedPermiso);
    _refreshUser();
  }

  Future<void> _updateUser(int id) async {
    await SQLHelper.updateUser(
        id,
        _nombreEditingController.text,
        _passEditingController.text,
        _descripcionEditingController.text,
        _correoEditingController.text,
        _selectedPermiso);
    _refreshUser();
  }

  Future<void> _deleteUser(int id) async {
    await SQLHelper.deleteUser(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Registro eliminado"),
    ));
    _refreshUser();
  }

  void muestraDatos(int? id) {
    if (id != null) {
      final existingUser = _allUser.firstWhere((element) => element['id'] == id);
      _nombreEditingController.text = existingUser['user_name'];
      _passEditingController.text = existingUser['pass'];
      _descripcionEditingController.text = existingUser['descripcion'];
      _correoEditingController.text = existingUser['correo'];
      _selectedPermiso = existingUser['permiso'];
    } else {
      _nombreEditingController.clear();
      _passEditingController.clear();
      _descripcionEditingController.clear();
      _correoEditingController.clear();
      _selectedPermiso = 'Visitante';
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
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
                  controller: _nombreEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Nombre",
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Contraseña",
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descripcionEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Descripción",
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _correoEditingController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Correo Electrónico",
                  ),
                ),
                SizedBox(height: 10),
                InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: "Permiso del Usuario",
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPermiso,
                      isDense: true,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setModalState(() {
                          _selectedPermiso = newValue!;
                        });
                      },
                      items: ['Administrador', 'Visitante']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addUser();
                      } else {
                        await _updateUser(id);
                      }
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 18),
                      child: Text(
                        id == null ? "Agregar Usuario" : "Actualizar Usuario",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEAF4),
      appBar: AppBar(
        title: Text("Listado de Usuarios"),
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
              itemCount: _allUser.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.all(15),
                child: ListTile(
                  title: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _allUser[index]['user_name'],
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Text("ID: ${_allUser[index]['id']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          muestraDatos(_allUser[index]['id']);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.amberAccent,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteUser(_allUser[index]['id']);
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
        onPressed: () => muestraDatos(null),
        child: Icon(Icons.add),
      ),
    );
  }
}