import 'package:ejercicio1/db_helper.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailHelper {

  static Future<void> send(List<Map<String, dynamic>> productosCarrito) async {
    String username = 'ruanoarmando54@gmail.com';
    String password = 'ivug vjrw ksas jaos';
    String? destino = SQLHelper.userEmail;
    final smtpServer = gmail(username, password);

    if (destino == null || destino.isEmpty) {
      return;
    }

    String productosInformacion = '';
    double costoTotal = 0;

    // Obtiene la informacion de los productos
    for (var producto in productosCarrito) {
      var detallesProducto = await SQLHelper.getSingleProducto(producto['id_producto']);
      if (detallesProducto.isNotEmpty) {
        var infoProducto = detallesProducto.first;
        double precioTotal = infoProducto['precio'] * producto['cantidad_producto'];
        costoTotal += precioTotal;

        productosInformacion += """
          <tr>
            <td><img src="${infoProducto['imagen']}" width="100" height="100"></td>
            <td>${infoProducto['nombre_producto']}</td>
            <td>${producto['cantidad_producto']}</td>
            <td>\$${precioTotal.toStringAsFixed(2)}</td>
          </tr>
        """;
      }
    }

    String htmlMessage = """
      <h1>Gracias por tu compra en Don Baratón</h1>
      <p>Detalles de la compra:</p>
      <table border="1" style="border-collapse: collapse; width: 100%;">
        <tr>
          <th>Imagen</th>
          <th>Producto</th>
          <th>Cantidad</th>
          <th>Precio Total</th>
        </tr>
        $productosInformacion
      </table>
      <h3>Total de la compra: \$${costoTotal.toStringAsFixed(2)}</h3>
    """;

    // Crear el mensaje
    final message = Message()
      ..from = Address(username, 'Don Baratón')
      ..recipients.add(destino)
      ..subject = 'Compra en Don Baratón :: ${DateTime.now()}'
      ..html = htmlMessage;

    // Crear una conexión persistente
    var connection = PersistentConnection(smtpServer);

    // Enviar el mensaje
    await connection.send(message);

    // Cerrar la conexión
    await connection.close();
  }
}
