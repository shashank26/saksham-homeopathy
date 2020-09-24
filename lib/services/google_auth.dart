import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class GoogleAuth {
  GoogleHttpClient _client;
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/youtube',
    ],
  );

  Stream<GoogleSignInAccount> onCurrentUserChanged;

  GoogleAuth._() {
    onCurrentUserChanged = _googleSignIn.onCurrentUserChanged;
  }

  static GoogleAuth instance;

  static GoogleAuth instantiate() {
    if (instance == null) {
      instance = GoogleAuth._();
    }
    return instance;
  }

  Future<bool> isSignedIn() {
    return _googleSignIn.isSignedIn();
  }

  getCurrentUser() {
    return _googleSignIn.currentUser;
  }

  signIn() async {
    GoogleSignInAccount signIn = await _googleSignIn.signInSilently();
    if (signIn == null) {
      await _googleSignIn.signIn();
    }
  }

  Future signOut() async {
    _googleSignIn.signOut();
  }

  getClient() async {
    if (_client != null) {
      return _client;
    }
    final authHeaders = await _googleSignIn.currentUser.authHeaders;
    return GoogleHttpClient(authHeaders);
  }
}

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Object url, {Map<String, String> headers}) =>
      super.head(url, headers: headers..addAll(_headers));
}
