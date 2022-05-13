import 'dart:io';

import 'package:flutter/material.dart';
import 'package:formvalidation/src/models/producto_model.dart';
import 'package:formvalidation/src/utils/utils.dart' as utils;
import 'package:image_picker/image_picker.dart';

import '../providers/productos_provider.dart';

class ProductoPage extends StatefulWidget {
  @override
  State<ProductoPage> createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  File? imageFile = null;

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final productoProvider = new ProductosProvider();

  ProductoModel producto = new ProductoModel();
  bool _guardando = false;
  // File? imageFile;

  @override
  Widget build(BuildContext context) {
    final Object? prodData = ModalRoute.of(context)?.settings.arguments;

    // final ProductoModel prodData= ModalRoute.of(context)?.settings.arguments as ProductoModel;
    if (prodData != null) {
      producto = prodData as ProductoModel;
    }

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: <Widget>[
          IconButton(
              onPressed: _obtenerGaleria,
              icon: Icon(Icons.photo_size_select_actual)),
          IconButton(onPressed: _obtenerFoto, icon: Icon(Icons.camera_alt))
        ],
      ),
      body: SingleChildScrollView(
          child: Container(
        padding: EdgeInsets.all(15.0),
        child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                _crearBoton(),
              ],
            )),
      )),
    );
  }

  Widget _crearNombre() {
    return TextFormField(
      initialValue: producto.titulo,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: 'Producto'),
      onSaved: (value) => producto.titulo = value.toString(),
      validator: (value) {
        if (value!.length < 3) {
          return 'Ingrese el nombre del producto';
        } else {
          return null;
        }
      },
    );
  }

  Widget _crearPrecio() {
    return TextFormField(
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: 'Precio'),
      onSaved: (value) => producto.valor = double.parse(value.toString()),
      validator: (value) {
        if (utils.isNumeric(value!)) {
          return null;
        } else {
          return 'Solo números';
        }
      },
    );
  }

  Widget _crearBoton() {
    return ElevatedButton.icon(
        onPressed: (_guardando) ? null : _submit,
        icon: Icon(Icons.save),
        label: Text('Guardar'),
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          )),
          elevation: MaterialStateProperty.all(0.0),
          backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
        ));
  }

  Widget _crearDisponible() {
    return SwitchListTile(
        title: Text('Disponible'),
        value: producto.disponible,
        activeColor: Colors.deepPurple,
        onChanged: (value) {
          setState(() {
            producto.disponible = value;
          });
        });
  }

  void _submit() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    setState(() {
      _guardando = true;
    });

    if (imageFile != null) {
      producto.fotoUrl = await productoProvider.subirImagen(imageFile!);
    }

    if (producto.id == null) {
      productoProvider.crearProducto(producto);
      print('Creo el objeto');
      _mostrarSnackbar('Registro hecho');
    } else {
      productoProvider.editarProducto(producto);
      print('Actualizo el objeto');
      _mostrarSnackbar('Registro actualizado');
    }
    Navigator.pop(context);
  }

  void _mostrarSnackbar(String mensaje) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      duration: Duration(microseconds: 3000),
    );
    scaffoldKey.currentState?.showSnackBar(snackBar);
  }

  _obtenerGaleria() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      producto.fotoUrl = null;
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  _obtenerFoto() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      producto.fotoUrl = null;
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  _mostrarFoto() {
    if (producto.fotoUrl != null) {
      return FadeInImage(
        placeholder: AssetImage('assets/jar-loading.gif'),
        image: NetworkImage(producto.fotoUrl!),
        height: 300.0,
        fit: BoxFit.contain,
      );
    } else {
      if (imageFile != null) {
        return Image.file(
          imageFile!,
          fit: BoxFit.cover,
          height: 300.0,
        );
      }
      return Image.asset('assets/noimage.png');
    }
  }
}
