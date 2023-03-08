import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";
final String contatcTable = "contatcTable";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

 Database? _db;

  get db async {
    if (_db != null) {
      return _db;
    }else{
          return _db = await initDb();

    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contactsnew.db");
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE  $contatcTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT , $phoneColumn TEXT, $imgColumn TEXT)");
      },
    );
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contatcTable, contact.toMap());
    return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(
      contatcTable,
      columns: [idColumn, nameColumn, imgColumn, emailColumn, phoneColumn],
      where: "$idColumn  =? ",
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  deleteContact(int id) async {
    Database dbContact = await db;
    dbContact.delete(contatcTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  updateContact(Contact contact) async {
    Database dbContact = await db;
    dbContact.update(
      contatcTable,
      contact.toMap(),
      where: "$idColumn = ?",
      whereArgs: [contact.id],
    );

  }
  Future<int? > getNumber()async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(await  dbContact.rawQuery("SELECT COUNT(*) FROM $contatcTable"));
    
  }
     Future<List<Contact>> getAllContact() async{
        Database dbContact = await db;
        List listMap = await dbContact.rawQuery("SELECT * FROM $contatcTable");
         List<Contact> listContact = [];
         for (Map m in listMap) {
            listContact.add(Contact.fromMap(m));

         }

         return listContact;
    }

}

class Contact {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;
  Contact();
  Contact.fromMap(Map<dynamic, dynamic> map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }
  Map<String, dynamic?> toMap() {
    Map<String, dynamic?> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }

    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "$id $name $email $img $phone";
  }
}
