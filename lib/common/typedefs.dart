import 'package:firebase_auth/firebase_auth.dart';
import 'package:saksham_homeopathy/models/message_image_info.dart';

import 'constants.dart';

typedef void AuthCallBack(LoginState loginState, String verificationId);
typedef void PhotoUploadCallBack(double progress, List<MessageImageInfo> messageImageInfo);
typedef String ImageMessagePath(FirebaseUser user);
typedef String ProfilePhotoPath(FirebaseUser user);