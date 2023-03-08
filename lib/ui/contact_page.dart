import 'dart:io';

import 'package:app_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class ContactPage extends StatefulWidget {
  Contact? contact;
  ContactPage({this.contact});
  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final focusName = FocusNode();
  bool _userEdited = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  Contact? _editContact;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.contact == null) {
      _editContact = Contact();
    } else {
      _editContact = Contact.fromMap(widget.contact!.toMap());

      _nameController.text = _editContact!.name!;
      if(_editContact!.email != null ){
        _emailController.text = _editContact!.email!;

      }
      if(_editContact!.phone != null )
              _phoneController.text = _editContact!.phone!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(_editContact!.name ?? "Novo Contato"),
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_editContact!.name!.isNotEmpty &&
                  _editContact!.name != null) {
                Navigator.pop(context, _editContact);
              } else {
                FocusScope.of(context).requestFocus(focusName);
              }
            },
            backgroundColor: Colors.red,
            child: Icon(
              Icons.save,
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    ImagePicker.platform.pickImage(source: ImageSource.camera).then((value){
                      if(value == null) return;
                  setState(() {
                     _editContact!.img = value.path;

                  });
                    });
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _editContact!.img != null
                            ? Image.file(File(_editContact!.img!)).image
                            : AssetImage("image/person.png"),
                            fit: BoxFit.cover
                      ),
                    ),
                  ),
                ),
                TextField(
                  focusNode: focusName,
                  decoration: InputDecoration(labelText: "Nome"),
                  onChanged: (value) {
                    _userEdited = true;
                    setState(() {
                      _editContact!.name = value;
                    });
                  },
                  controller: _nameController,
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  onChanged: (value) {
                    _userEdited = true;
                    setState(() {
                      _editContact!.email = value;
                    });
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: "Phone"),
                  onChanged: (value) {
                    _userEdited = true;
                    setState(() {
                      _editContact!.phone = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        onWillPop: _requestPop);
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidos."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar"),
                ),
                 TextButton(
                  onPressed: () {
                     Navigator.pop(context);
                      Navigator.pop(context);
                  },
                  child: Text("Descartar"),
                )

              ],
            );
          },);
       return   Future.value(false);
    }else{
      return  Future.value(true);
    }
  }
}
