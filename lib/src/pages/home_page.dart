import 'package:flutter/material.dart';
import 'package:formvalidation/src/blocs/provider.dart';
import 'package:formvalidation/src/models/producto_model.dart';
import 'package:formvalidation/src/providers/productos_provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final productosProvider = new ProductosProvider();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of(context); //Recibe

    return Scaffold(
      appBar: AppBar(title: Text('Home page')),
      body: _crearListado(),
      floatingActionButton: _crearBoton(context),
    );
  }

  Widget _crearListado() {
    return FutureBuilder(
        future: productosProvider.cargarProductos(),
        builder: (BuildContext context,
            AsyncSnapshot<List<ProductoModel>> snapshot) {
          if (snapshot.hasData) {
            final productos = snapshot.data;
            return ListView.builder(
                itemCount: productos?.length,
                itemBuilder: (context, i) =>
                    _crearItem(context, productos![i]));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget _crearItem(BuildContext context, ProductoModel producto) {
    return Dismissible(
        key: UniqueKey(),
        background: Container(
          color: Colors.red,
        ),
        onDismissed: (direccion) {
          productosProvider.borrarProducto(producto.id!);
        },
        child: Card(
          child: Column(children: <Widget>[
            (producto.fotoUrl == null)
                ? Image(
                    image: AssetImage('assets/noimage.png'),
                    width: 500.0,
                  )
                : FadeInImage(
                    placeholder: AssetImage('assets/jar-loading.gif'),
                    image: NetworkImage(producto.fotoUrl!),
                    height: 600.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
            ListTile(
                title: Text('${producto.titulo} - ${producto.valor}'),
                subtitle: Text(producto.id.toString()),
                onTap: () {
                  setState(() {});
                  Navigator.pushNamed(context, 'producto', arguments: producto);
                }),
          ]),
        ));
  }

  _crearBoton(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () => Navigator.pushNamed(context, 'producto'),
    );
  }
}
