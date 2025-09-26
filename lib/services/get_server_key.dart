import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> GetServiceKeyToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "let-s-shop-47c2a",
        "private_key_id": "352251fa9a568a6cbf66de17dc72b84bb4ca05fd",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEugIBADANBgkqhkiG9w0BAQEFAASCBKQwggSgAgEAAoIBAQCL+mGENyMzMVXO\nGPHbOacWb3SEi9gbQqsh++U57QJR9x8B7MQdU7H7otU9/R5NweEjACOusYLO243A\nkG2Tnx/PEBI1GxJUyVhOy4ttNJZRjFj6YZ7ra5l1ZddEGKveMQYkZVOqQJmEKjs2\n5AEzRSYbMSvQz1nprxNIpvchtd1G/5N+kTeVWpYD2F/P5/h4BnCaWG9UsuVLtynI\nFkyvhKilQNMDOzzn75deLdHGsrI8jNh1/26AFcPgN0pJc3qhWLlm51qcMaiFdDYc\nrDwetqfjHtEUJoorn59bUKt+HPAcVrkCJqUPIwWSerG3kdctdpeVatPmwCQ7HprV\nJKMQvzPPAgMBAAECgf8FxRhxh2ICgdWQXZnVCs+1aYBWOKQGMxhO6Mtz7vgeCERW\nr+AseQzJzcXedD0SABNREt7ZAuyPWycbWX8327ZJ77T8yjhejyW3jvAx7RiTbXQ4\nRHwyEjzZiIGXSI8/HXk6Tldp8tlxki5TU8x+aZX/CZm3dJJVocAvvlhja1+Njh4r\nmm+7z8cFma1L5JIuvZNJq1+MXvAJlOBuPOX/kpF1f1onrVKI95zmn7C3TM76Au7l\nnGxzffUrhtqiLtQ/3HR58jQlEXd00nmIzCgN94eEjzlqoQ8xg+6Eeif/aLFd+jzW\ndLxauX3OxrR4B/TpDicQPgKBdN0RLN9GfHN3r4ECgYEAvWLg8gnB+x/1jNjKKoDi\nTjs0r/iuvgBx8w6Qx2otyPgyo5UM1UecPDQ+F6UJu1wFZiNtcatbaBXtEDXKVBl4\nfMh0Tj46t8+BocR/QlEySOJrooBEBh6WU45+TdNmhwxDovyvfzv8XTq2w0V00SUm\ncxCXWxuj3Uy+p8YgyEw2XtUCgYEAvTaVe7cWBjl2Ezg0jkMYM6ODieEJoA9kWsgt\nMRksDEpTI0lkbk1hILAdOxytOpoKYHCxmu1TzbUdbTxiQUiwSOhBXRrBgSpw1rl1\nz8Qk0ggjzOKRreUgy5jDaAH4v+FlLoKvJU49cH/DqTfAGmuby8cRklJSKEaCNt2X\n2K1WghMCgYA1YTFWBzoNtixXzqLs5/bhZf6rusRF+Yokn+5exqaxBoP/Z3t+gfif\nX3pA39umW4GKEGJAr7PL2qI+92pX2fYD9dwSUafrNymqlt/nqUsrD+aWnuCNeQGV\n+4vOE8/KMMK/pckxa47uGCZ7U5Bhgr8bn4mJvHirX349e7KxwglxIQKBgDo0UEd+\nSogfpPLEl2YrvYYlBpGjaBKUqYpDiaNQ2vvs4SY5rWtA4l/rzRIiACfGuupvwDKo\nTt84l5TCvnbWpWPIDlNVp7DUHWHwKw1+iNUTK/AawjV8Blqa44FbGensq/Niv/35\n02yH4Ohs/esirwpAcmdQa3V4OxYllFBTAgmBAoGAc4a5Ft20YhwKqPGO2Atl4dDh\n/WO7QoYVMltTvM7UJBYA11zu0Lh7Lo34ghvMWd+RLms/YYXAWBM/Fs9Am/L+x4zK\nkx010/EXUouIBEiZzt82/2SGDH/3zMQHNVN4wmMtPIL5wg4vEM6RemLbO2KRSkvJ\n8exJFWx7GBSwVBRyMbo=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-fbsvc@let-s-shop-47c2a.iam.gserviceaccount.com",
        "client_id": "110247058530473814076",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40let-s-shop-47c2a.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      }),
      scopes,
    );
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
