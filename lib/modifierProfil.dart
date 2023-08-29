import 'package:flutter/material.dart';
import 'package:projectkiaforest/mediaQuery/sizeHelpers.dart';
import 'package:projectkiaforest/customTextField.dart';
class EditProfilePage extends StatefulWidget {
  final String username;
  final String phoneNumber;
  final String residence;
  final String status;

  EditProfilePage({
    required this.username,
    required this.phoneNumber,
    required this.residence,
    required this.status,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _residenceController;
  String _selectedStatus = '';

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _phoneNumberController = TextEditingController(text: widget.phoneNumber);
    _residenceController = TextEditingController(text: widget.residence);
    _selectedStatus = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
      primaryColor: Color(0xCC458535),),
      child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Colors.grey,
                    offset: Offset(2, 6),
                  ),
                ],
                color: Color(0xCC458535),
              ),
              height: displayHeight(context) * 0.45,
              width: displayWidth(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                  SizedBox(width: 10,),
                    InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 28,
                        color: Color(0xCC458535),
                      ),
                    ),
                  ),
                  ]
    ),
    ),
                  SizedBox(height: displayHeight(context) * 0.08,),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 60,
                    child: Text(
                      'BA',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'BODEHOU Alfred',
                    style: TextStyle(color: Colors.white, fontSize: displayWidth(context) * 0.062 ),
                  ),
                ],
              ),

            ),
            SizedBox(height: 30,),
            Text(
              'Nom d\'utilisateur                                 ',
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 18),
            ),
            CustomTextField(controller: _usernameController, hintText: widget.username, prefixicon: Icons.person, keybaordType: TextInputType.text),
            SizedBox(height: 10),
            Text(
              'Numéro                                                 ',
              style: TextStyle(fontSize: 18),
            ),
            CustomTextField(controller: _phoneNumberController, hintText: widget.phoneNumber, prefixicon: Icons.phone, keybaordType: TextInputType.number),
            SizedBox(height: 10),
            Text(
              'Lieu de résidence                                  ',
              style: TextStyle(fontSize: 18),
            ),
            CustomTextField(controller: _residenceController, hintText: widget.residence, prefixicon: Icons.home, keybaordType: TextInputType.text)
            ,SizedBox(height: 10),
            Text(
              'Statut                                                       ',
              style: TextStyle(fontSize: 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: 'Acheteur',
                  groupValue: _selectedStatus,
                  activeColor: Color(0xCC458535),
                  focusColor: Color(0xCC458535),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                Text('Acheteur'),
                SizedBox(width: 20),
                Radio<String>(
                  value: 'Ramasseur',
                  groupValue: _selectedStatus,
                  activeColor: Color(0xCC458535),
                  focusColor: Color(0xCC458535),
                  hoverColor: Color(0xCC458535),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                Text('Ramasseur'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Mettre à jour les informations de profil ici
              },
              child: Text('Mettre à jour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xCC458535),
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 60,),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),

            SizedBox(height: displayHeight(context) * 0.2,),
          ],
        ),
      ),
      ),
    );
  }
}
