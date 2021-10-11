import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';

import 'package:vehicles_app/components/loader_component.dart';
import 'package:vehicles_app/helpers/api_helper.dart';
import 'package:vehicles_app/models/document_type.dart';

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

  String _lastName= '';
  String _lastNameError='';
  bool _lastNameShowError= false;
  TextEditingController _lastNameController= TextEditingController();


  DocumentType _documentType= DocumentType(id: 0, description: '');
  List<DocumentType> _documentTypes= [];

  String _document= '';
  String _documentError='';
  bool _documentShowError= false;
  TextEditingController _documentController= TextEditingController();

  String _address= '';
  String _addressError='';
  bool _addressShowError= false;
  TextEditingController _addressController= TextEditingController();

  String _email= '';
  String _emailError='';
  bool _emailShowError= false;
  TextEditingController _emailController= TextEditingController();

  String _phoneNumber= '';
  String _phoneNumberError='';
  bool _phoneNumberShowError= false;
  TextEditingController _phoneNumberController= TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _firstname= widget.user.firstName;
    _firstnameController.text= _firstname;

    _lastName= widget.user.lastName;
    _lastNameController.text= _lastName;

    _documentType= widget.user.documentType;

    _document= widget.user.document;
    _documentController.text= _document;
    
    _address= widget.user.address;
    _addressController.text= _address;

    _email= widget.user.email;
    _emailController.text= _email;

    _phoneNumber= widget.user.phoneNumber;
    _phoneNumberController.text= _phoneNumber;
    
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
            SingleChildScrollView(
              child: Column(
                children:<Widget>[
                  _showPhoto(),
                  _showFirstName(),
                  _showLastName(),
                  _showDocumentType(),
                  _showDocument(),
                  _showEmail(),
                  _showAddress(),
                  _showPhoneNumber(),
                  _showButtons(),
                ],
              ),
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

  Widget _showPhoto() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: widget.user.id.isEmpty
      ? Image(
        image: AssetImage('assets/noimage.png'),
        height: 160,
        width: 160,
        )
      : ClipRRect(
          borderRadius:BorderRadius.circular(80),
          child: FadeInImage(
            placeholder: AssetImage('assets/Logo.png'),
            image: NetworkImage(widget.user.imageFullPath),
            width:160,
            height: 160,
            fit: BoxFit.cover,
          ),
        ),
    );
  }

  Widget _showLastName() {
    return Container(
        padding: EdgeInsets.all(10),
        child: TextField(
        controller: _lastNameController,
          decoration: InputDecoration(
            hintText: 'Ingrese apellidos...' ,
            labelText: 'Nombres',
            errorText: _lastNameShowError? _lastNameError: null,
            suffixIcon: Icon(Icons.person),
           border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10) )
          ),
          onChanged: (value){
          _lastName= value;
        
          }
        ),
     
    );
  }

  Widget _showDocumentType() {
    //TODO: pending to implemet
    return Container();
  }

  Widget _showDocument() {
    return Container(
        padding: EdgeInsets.all(10),
        child: TextField(
        controller: _documentController,
          decoration: InputDecoration(
            hintText: 'Ingrese documento...' ,
            labelText: 'Documento',
            errorText: _documentShowError? _documentError: null,
            suffixIcon: Icon(Icons.assignment_ind),
           border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10) )
          ),
          onChanged: (value){
          _document= value;
        
          }
        ),
     
    );
  }

  Widget _showEmail() {
    return Container(
        padding: EdgeInsets.all(10),
        child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Ingrese email...' ,
            labelText: 'Email',
            errorText: _emailShowError? _emailError: null,
            suffixIcon: Icon(Icons.email),
           border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10) )
          ),
          onChanged: (value){
          _email= value;
        
          }
        ),
     
    );
  }

  Widget _showAddress() {
    return Container(
        padding: EdgeInsets.all(10),
        child: TextField(
        controller: _addressController,
        keyboardType: TextInputType.streetAddress,
        decoration: InputDecoration(
          hintText: 'Ingrese direccion...' ,
          labelText: 'Direccion',
          errorText: _addressShowError? _addressError: null,
          suffixIcon: Icon(Icons.home),
          border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10) )
        ),
          onChanged: (value){
          _address= value;
        
          }
        ),
     
    );
  }

  Widget _showPhoneNumber() {
    return Container(
        padding: EdgeInsets.all(10),
        child: TextField(
        controller: _phoneNumberController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: 'Ingrese telefono...' ,
          labelText: 'Telefono',
          errorText: _phoneNumberShowError? _phoneNumberError: null,
          suffixIcon: Icon(Icons.phone),
          border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10) )
        ),
          onChanged: (value){
          _phoneNumber= value;
        
          }
        ),
     
    );
  }
}