import 'dart:io';

import 'package:app_contatos/helpers/contact_helper.dart';
import 'package:app_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOption { orderaz, orderza }

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper contactHelper = ContactHelper();
  List<Contact> contacts = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOption>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOption>>[
              const PopupMenuItem(
                child: Text("Ordenar de A-Z"),
                value: OrderOption.orderaz,
              ),
              const PopupMenuItem(
                child: Text("Ordenar de Z-A"),
                value: OrderOption.orderza,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
        padding: EdgeInsets.all(10),
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null
                        ? Image.file(File(contacts[index].img!)).image
                        : AssetImage("image/person.png"),
                        fit: BoxFit.cover
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contacts[index].name ?? " ",
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    contacts[index].email ?? " ",
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  Text(
                    contacts[index].phone ?? " ",
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOption(context, index);
      },
    );
  }

  void _showOption(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextButton(
                          onPressed: () {
                            final Uri uri =
                                Uri(scheme: 'tel', path: contacts[index].phone);
                            launchUrl(uri);
                          },
                          child: Text(
                            "Ligar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactPage(contact: contacts[index]);
                          },
                          child: Text(
                            "Editar",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextButton(
                          onPressed: () {
                            contactHelper.deleteContact(contacts[index].id!);
                            setState(() {
                              contacts.remove(index);
                              Navigator.pop(context);
                            });
                          },
                          child: Text(
                            "Excluir",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  void _showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(contact: contact),
      ),
    );
    if (recContact != null) {
      if (contact != null) {
        await contactHelper.updateContact(recContact);
      } else {
        await contactHelper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    contactHelper.getAllContact().then((value) {
      setState(() {
        contacts = value;
      });
    });
  }

  void _orderList(OrderOption value) {
    switch(value){
      case OrderOption.orderaz:
        contacts.sort(((a, b) {
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        }));
      break;
      case OrderOption.orderza:
        contacts.sort(((a, b) {
          return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
        }));
      break;
    }
    setState(() {
      contacts;
    });
  }
}
