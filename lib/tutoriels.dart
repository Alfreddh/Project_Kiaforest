import 'package:flutter/material.dart';
import 'package:projectkiaforest/mediaQuery/sizeHelpers.dart';

class singleTuto extends StatefulWidget {
  const singleTuto({Key? key}) : super(key: key);

  @override
  State<singleTuto> createState() => _singleTutoState();
}

class _singleTutoState extends State<singleTuto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/image3.jpg"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            width: double.infinity,
            height: displayHeight(context) * 0.35,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite,
                          size: 24,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
          SizedBox(height: 15,),
          Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Adansonia Digitata",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15,),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8,),
                Text(
                  "Ensuite, nous avons inclus un bouton élevé dans la méthode build qui utilise _isLoading pour désactiver le bouton si le chargement est en cours. Le bouton affiche soit le texte ou un CircularProgressIndicator, en fonction de l'état de _isLoading.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 10,),
                InkWell(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: displayWidth(context) * 0.65),
                    child: Text(
                      'Lire plus',
                      style: TextStyle(
                        //decoration: TextDecoration.underline,
                          color: Colors.green,
                          fontWeight: FontWeight.w500
                      ),
                      //textAlign: TextAlign.right,
                    ),
                  ),
                ),


              ],
            ),
          ),
          SizedBox(height: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "Autres tutoriels",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 5,),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(left: displayWidth(context) * 0.75),
                  child: Text(
                    'Voir plus',
                    style: TextStyle(
                      //decoration: TextDecoration.underline,
                        color: Colors.green,
                        fontWeight: FontWeight.w500
                    ),
                    //textAlign: TextAlign.right,
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for(int i=1; i<6; i++)
                      Container(
                        height: 90,
                        width: 90,
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(top: 8, bottom: 8, left: 20),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("images/image$i.jpg"),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 8,
                              ),
                            ]
                        ),

                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
