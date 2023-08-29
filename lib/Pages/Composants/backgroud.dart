import 'package:flutter/material.dart';
import 'package:projectkiaforest/Pages/Composants/bouton.dart';
//import 'package:projectkiaforest/Pages/validation.dart';
import 'package:custom_clippers/custom_clippers.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';



class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  _popup_forgot(size) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              backgroundColor: Colors.green,
              // title: Container( color: Colors.black,child: Image.asset('assets/images/back1.jpg')),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              // title: Text('Nous avions envoye un au numero +22952623705'),
              contentPadding: EdgeInsets.all(0),
              content: Stack(
                // alignment: Alignment.center,
                children: [
                  ClipPath(
                      clipper: DirectionalWaveClipper(verticalPosition:VerticalPosition.top, horizontalPosition: HorizontalPosition.right),
                      child: Container(
                        // padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30), topRight: Radius.circular(30))
                        ),
                        // padding: EdgeInsets.only(left: 20, right: 20),
                        width: size.width,
                        height: size.height/3,
                        // margin: EdgeInsets.only(top: 40),
                        child: Wrap(

                          children: [
                            Container(
                                margin: EdgeInsets.only(top: 40),
                                child: Text('Un SMS contenant un code de validation est envoye au numero ******',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                )
                            ),
                            Text('Entrer le code', style: TextStyle(fontWeight: FontWeight.bold),),
                            Container(
                              // color: Colors.grey,
                              margin: EdgeInsets.only(top: 5,),
                              child: OtpTextField(
                                fillColor: Colors.black12,
                                margin: EdgeInsets.all(2),
                                numberOfFields: 5,
                                borderColor: Color(0xFF512DA8),
                                focusedBorderColor: Colors.green,
                                enabledBorderColor: Colors.green,
                                borderWidth: 3,
                                //set to true to show as box or false to show as dash
                                showFieldAsBox: true,
                                //runs when a code is typed in
                                onCodeChanged: (String code) {
                                  //handle validation or checks here
                                },
                                //runs when every textfield is filled
                                onSubmit: (String verificationCode){
                                  showDialog(
                                      context: context,
                                      builder: (context){
                                        return AlertDialog(
                                          title: Text("Verification Code"),
                                          content: Text('Code entered is $verificationCode'),
                                        );
                                      }
                                  );
                                }, // end onSubmit
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                ],
              )
          );
        });

  }


  void _showLoginModal(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    final _formKey = GlobalKey<FormState>();
    String phonenumber = '';
    final TextEditingController _phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: 300,
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Connexion',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Numéro de téléphone',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            phonenumber = value;
                          });
                        },
                        controller: _phoneController,
                        decoration: InputDecoration(
                          prefixIcon: Image.asset(
                            'images/beninflag.jpg',
                            height: 24.0,
                            width: 24.0,
                          ),
                          labelText: '+229',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Colors.green.shade100,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Colors.green.shade100,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                              color: Colors.green,
                              width: 2.0,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Veuillez entrer un numéro de téléphone valide.';
                          }
                        },
                      ),
                      SizedBox(height: 24.0),
                      ElevatedButton(

                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: Submit the phone number and connect the user.
                            _popup_forgot(size);
                          }
                        },
                        child: Text(
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xCC458535),
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top:0),
            padding: EdgeInsets.only(top: 100.0, left: size.width * 0.05),
            height: size.height * 0.75,
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/image.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 30,),
                Text(
                  "KIAFOREST",
                  style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 50,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        blurRadius: 2,
                        color: Colors.white38,
                        offset: Offset(2, 1),
                      ),

                    ],
                    fontFamily: 'Pokemon',
                  ),
                ),
                SizedBox(height: size.height * 0.25,),
                Text('Achetez ou Vendez des produits forestiers non ligneux ici',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: size.height * 0.25,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xAA536957), Color(0XFF002407)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: size.height * 0.07,),
                RoundedButton(
                  text: "Se connecter",
                  press: (){
                    //var root = MaterialPageRoute(builder: (BuildContext context) => LoginPage() );
                    //Navigator.of(context).push(root);
                    _showLoginModal(context);

                  },
                ),

              ],
            ),
          ),



        ],
      ),
    );
  }
}

