import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:users_app/authenfication/login_screen.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/widgets/loading_dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
{
  TextEditingController  userNametextEditingController= TextEditingController();
  TextEditingController  userPhonetextEditingController= TextEditingController();
  TextEditingController  emailtextEditingController= TextEditingController();
  TextEditingController  passwordtextEditingController= TextEditingController();
  //
  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;
  String urlOfUploadedImage="";

  //Check Internet Connection
  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);

    if(imageFile!= null)//image validation
        {
      signUpFromValidation();
    }
    else
    {
      cMethods.displaySnackBar("Please choose image first. ", context);
    }
  }


  signUpFromValidation(){
    if(userNametextEditingController.text.trim().length<3){
      cMethods.displaySnackBar("your name must be atleast 4 or more characters", context);
    }
    else if(userPhonetextEditingController.text.trim().length<7){
      cMethods.displaySnackBar("your phone number must be atleast 8 or more characters", context);

    }
    else if(!emailtextEditingController.text.contains("@")){
      cMethods.displaySnackBar("please write valid email", context);

    }
    else if(passwordtextEditingController.text.trim().length<5){
      cMethods.displaySnackBar("your password must be atleast 6 or more characters", context);

    }
    else
      {
        uploadImageToStorage();
       /// registerNewUser();
      }
  }

  uploadImageToStorage() async
  {
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    //save by unique ID name
    Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);
//convert XFile to File and download it

    UploadTask uploadTask=referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot= await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState((){
      urlOfUploadedImage;
    });

    registerNewUser();
  }

  registerNewUser() async
  {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "Registring your account..."),
    );

    final User? userFirebase = (
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailtextEditingController.text.trim(),
          password: passwordtextEditingController.text.trim(),
      ).catchError((errorMsg)
      {
        Navigator.pop(context);
        cMethods.displaySnackBar(errorMsg.toString(), context);
      })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef= FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);//unique id

    Map userDataMap=
        {
          "photo":urlOfUploadedImage,
          "name": userNametextEditingController.text.trim(),
          "email": emailtextEditingController.text.trim(),
          "phone": userPhonetextEditingController.text.trim(),
          "id": userFirebase.uid,
          "blockStatus":"no",//user not blocked been proved the account if it s yes mean it s blocked
        };

    usersRef.set(userDataMap);
    
    
    
    Navigator.push(context, MaterialPageRoute(builder: (c)=>HomePage()));

    
  }


  chooseImageFromGallery() async
  {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(pickedFile!=Null)
    {
      setState(() {
        imageFile= pickedFile;

      });
    }

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
            Text(
              "Create a User\'s Account",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

              const SizedBox(
                height: 40,
              ),

              imageFile == null ?
              const CircleAvatar(
                radius: 86,
                backgroundImage: AssetImage("assets/images/avatarnor.png"),
              ): Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: FileImage(
                        File(
                            imageFile!.path

                        ),
                      )
                  ),

                ),

              ),

              const SizedBox(
                height: 10,
              ),

              GestureDetector(
                onTap: ()
                {
                  chooseImageFromGallery();

                },
                child: const Text(
                  "Choose Image",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ),
            //text fields + button
            Padding(
              padding:const EdgeInsets.all(22),
              child: Column(
                children: [

                  TextField(
                    controller: userNametextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "User Name",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 22,),

                  TextField(
                    controller: userPhonetextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "User Phone",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 22,),

                  TextField(
                    controller: emailtextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "User Email",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 22,),

                  TextField(
                    controller: passwordtextEditingController,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "User Password",
                      labelStyle: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 32,),

                  ElevatedButton(
                      onPressed: (){
                        checkIfNetworkIsAvailable();

                      },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 80,vertical: 10)
                    ),
                    child: const Text(
                      "Sign Up"
                    ),
                  ),
                ],
              ),
            ),


              const SizedBox(height: 12,),

              //Text Button
              TextButton(
                onPressed:(){
                  Navigator.push(context, MaterialPageRoute(builder: (c)=>LoginScreen()));

                },
                child: Text(
                  "Already have an Account? Login Here",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }


}
