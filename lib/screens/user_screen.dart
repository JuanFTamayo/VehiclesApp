import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';

import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';

import 'package:vehicles_app/models/response.dart';
import 'package:vehicles_app/models/token.dart';
import 'package:vehicles_app/models/user.dart';

class UserScreen extends StatefulWidget {
  final Token token;
  final User user;

  UserScreen({required this.token, required this.user});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _showLoader= false;
  

  String _firstname= '';
  String _firstnameError='';
  bool _firstnameShowError= false;
  TextEditingController _firstnameController= TextEditingController();


  @override
  void initState() {
    super.initState();
    _firstname= widget.user.fullName;
    _firstnameController.text= _firstname;
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text(
          widget.user.id.isEmpty
          ? 'Nuevo usuario'
          : widget.user.fullName
          ),
          
        ), 
        body: Stack(
          children: [
            Column(
              children:<Widget>[
                _showFirstName(),
                _showButtons(),
              ],
            ),
            _showLoader? LoaderComponent(text: 'Por favor espere...',): Container(),
          ],
        ),
    );
  }

  Widget _showFirstName() {
    return Container(
        padding: EdgeInsets.all(10),
        child: TextField(
          autofocus: true,
          controller: _firstnameController,
          decoration: InputDecoration(
            hintText: 'Ingrese nombres...' ,
            labelText: 'Nombres',
            errorText: _firstnameShowError? _firstnameError: null,
            suffixIcon: Icon(Icons.person),
           border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10) )
          ),
          onChanged: (value){
          _firstname= value;
        
          }
        ),
     
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10,right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:<Widget> [
          Expanded(
          child: ElevatedButton(
            child: Text('Guardar'),
            style: ButtonStyle(
              backgroundColor:MaterialStateProperty.resolveWith<Color>(
              (Set <MaterialState> states ){
                return Color(0xFF3DBE29);
              }
             ),
            ),
            onPressed: () => _save() ,
             
             ),
          ),
          
          widget.user.id.isEmpty
          ? Container() 
          : SizedBox(width: 20,),
          widget.user.id.isEmpty
          ? Container()
          :Expanded(
                child: ElevatedButton(
                  child: Text('Borrar'),
                  style: ButtonStyle(
                    backgroundColor:MaterialStateProperty.resolveWith<Color>(
                      (Set <MaterialState> states ){
                      return Color(0xFFBF3325);
                      }
                    ),
                  ),
                  onPressed: () => _confirmDelete(),
               
                ),
              ),
          
        ],
      ),
    );
  }

  void _save() {
    if (!_validateFields()) {
      return;
    }

    widget.user.id.isEmpty? _addRecord(): _saveRecord();
  }

  bool _validateFields() {
    bool isValid= true;

    if (_firstname.isEmpty) {
      isValid=false;
      _firstnameShowError = true;
      _firstnameError = 'Debes ingresar al menos un nombre'; 
    }
    else{
      _firstnameShowError= false;
    }

    setState(() {});
    return isValid;
  }

  _addRecord() async {
    setState(() {
      _showLoader= true;
    });

    Map <String, dynamic> request= {
      
      'firstname': _firstname,
    };

    Response response = await ApiHelper.post(
      '/api/Users/',
       request,
       widget.token.token
    );

    setState(() {
      _showLoader= false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
        context: context,
        title: 'Error',
        message: response.message,
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );
      return;
    }

    Navigator.pop(context,'yes');
  }

  _saveRecord() async {
    setState(() {
      _showLoader= true;
    });

    Map <String, dynamic> request= {
      'id': widget.user.id,
      'firstname': _firstname,
    };

    Response response = await ApiHelper.put(
      '/api/Users/',
       widget.user.id,
       request,
       widget.token.token
    );

    setState(() {
      _showLoader= false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
        context: context,
        title: 'Error',
        message: response.message,
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );
      return;
    }

    Navigator.pop(context,'yes');
  }

  void _confirmDelete() async {
    var response = await showAlertDialog(
        context: context,
        title: 'Confirmacion',
        message: 'Esta seguro de querer borrar el registro?',
        actions: <AlertDialogAction>[
          AlertDialogAction(key: 'no', label: 'No'),
          AlertDialogAction(key: 'yes', label: 'Si'),
        ]
      );
      if (response=='yes') {
        _deleteRecord();
      }
  }

  void _deleteRecord() async {
    setState(() {
      _showLoader= true;
    });

    

    Response response = await ApiHelper.delete(
      '/api/Users/',
       widget.user.id,
       widget.token.token
    );

    setState(() {
      _showLoader= false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
        context: context,
        title: 'Error',
        message: response.message,
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );
      return;
    }

    Navigator.pop(context,'yes');
  }
}