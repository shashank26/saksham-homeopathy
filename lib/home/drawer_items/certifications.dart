import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/image_modal_bottom_sheet_dialog.dart';
import 'package:saksham_homeopathy/common/image_swipe_view.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';
import 'package:saksham_homeopathy/services/image_picker.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';

class Certifications extends StatefulWidget {
  @override
  _CertificationsState createState() => _CertificationsState();
}

class _CertificationsState extends State<Certifications> {
  DocumentSnapshot _documentSnapshot;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List _uploadedImages = [];
  final imageURL =
      (String imageName) => FirebaseConstants.certificationsImageURL(imageName);
  final imagePath = (String imageName) => "certifications/$imageName";

  @override
  initState() {
    super.initState();
  }

  _uploadCertificate() async {
    try {
      ImageSource _imageSource;
      await pickImageSource(context, (ImageSource imageSource) {
        _imageSource = imageSource;
      });
      final _image = await CImagePicker.getImage(_imageSource);
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Uploading Image...'),
      ));
      final imageName = ImagePath.imageCertificationsPath();
      await FileHandler.instance.uploadFile(_image, this.imagePath(imageName));
      _uploadedImages.add(imageName);
      await _documentSnapshot.reference.update({'images': _uploadedImages});
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Completed'),
      ));
    } on Exception catch (e) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Some error occurred ${e.toString()}'),
      ));
    }
  }

  _showOptions(imageName) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 100,
            child: Column(
              children: [
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      FileHandler.instance
                          .deleteCloudFile(this.imagePath(imageName));
                      _uploadedImages.removeWhere((e) => e == imageName);
                      _documentSnapshot.reference
                          .update({'images': _uploadedImages});
                    },
                    child: Text("Delete")),
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel")),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black,
        floatingActionButton: Visibility(
          visible: OTPAuth.isAdmin,
          child: FloatingActionButton(
              backgroundColor: AppColorPallete.color,
              child: Icon(
                Icons.image,
                color: AppColorPallete.backgroundColor,
              ),
              onPressed: () async {
                await _uploadCertificate();
              }),
        ),
        appBar: AppBar(
          iconTheme: IconThemeData(color: AppColorPallete.textColor),
          backgroundColor: AppColorPallete.backgroundColor,
          title: Container(
              color: AppColorPallete.backgroundColor,
              child: HeaderText(
                "Awards and Accolades",
                align: TextAlign.left,
                size: 20,
              )),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirestoreCollection.certifications().snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data.docs.length > 0) {
                      _documentSnapshot = snapshot.data.docs.first;
                      _uploadedImages = _documentSnapshot.get('images');
                      if (_uploadedImages.length > 0) {
                        return GridView.builder(
                            itemCount: _uploadedImages.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 1, mainAxisSpacing: 10.0),
                            itemBuilder: (context, index) {
                              final imageName =
                                  _uploadedImages[index].toString();
                              return GestureDetector(
                                child: GridTile(
                                  child: NetworkOrFileImage(
                                      this.imageURL(imageName),
                                      null,
                                      this.imagePath(imageName)),
                                ),
                                onLongPress: () async {
                                  if (OTPAuth.isAdmin) {
                                    await _showOptions(imageName);
                                  }
                                },
                                onTap: () async {
                                  final imagePaths = _uploadedImages
                                      .map((e) => FileHandler.instance
                                          .getAbsolutePath(this.imagePath(e)))
                                      .toList();
                                  await imageSwipeView(context, index,
                                      imagePaths, "Awards and Accolades");
                                },
                              );
                            });
                      } else {
                        return Center(
                          child: HeaderText(
                            'Coming soon...',
                            color: AppColorPallete.backgroundColor,
                          ),
                        );
                      }
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
