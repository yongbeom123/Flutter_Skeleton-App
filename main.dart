import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/firestore/v1.dart' as firestore;
import 'package:mongo_dart/mongo_dart.dart' as mongo;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final String googleCloudApiKey = 'YOUR_GOOGLE_CLOUD_API_KEY';
  final String mongoDbUri = 'YOUR_MONGODB_URI';

  Future<void> _saveUserDataToCloudPlatform(String data) async {
    // 구글 클라우드 플랫폼에 사용자 데이터 저장
    final client = await auth.clientViaApiKey(googleCloudApiKey, scopes: []);
    final firestore.FirestoreApi firestoreApi = firestore.FirestoreApi(client);

    final document = firestore.Document()
      ..fields = (firestore.MapValue()
        ..fields = {
          'userData': firestore.Value()
            ..stringValue = data,
        });

    await firestoreApi.projects.databases.documents.patch(
      'projects/YOUR_PROJECT_ID/databases/(default)/documents/users/USER_ID',
      $fields: 'fields',
      document: document,
    );
  }

  Future<void> _saveUserDataToMongoDB(String data) async {
    // MongoDB에 사용자 데이터 저장
    final db = mongo.Db(mongoDbUri);
    await db.open();
    await db.collection('users').insert({'userData': data});
    await db.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Data Storage App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final userData = 'User data to be saved'; // 실제 사용자 데이터는 여기에 들어가야 합니다.

            try {
              await _saveUserDataToCloudPlatform(userData);
              await _saveUserDataToMongoDB(userData);
              // 데이터가 성공적으로 저장되었다는 메시지를 보여줄 수도 있습니다.
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Success'),
                  content: Text('User data saved successfully!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            } catch (e) {
              // 데이터 저장에 실패하면 에러 메시지를 보여줄 수도 있습니다.
              print('Error: $e');
            }
          },
          child: Text('Save User Data'),
        ),
      ),
    );
  }
}

