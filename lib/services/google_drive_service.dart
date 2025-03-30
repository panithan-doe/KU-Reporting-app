// import 'dart:async';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';


// /// A thin AuthClient that adds the user's auth headers
// class GoogleAuthClient extends http.BaseClient {
//   final Map<String, String> _headers;
//   final http.Client _client = http.Client();

//   GoogleAuthClient(this._headers);

//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//     return _client.send(request..headers.addAll(_headers));
//   }
// }

// class GoogleDriveService {
//   // Request the scope to create/manage files in the user's Drive.
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: <String>[
//       'https://www.googleapis.com/auth/drive.file',
//     ],
//   );

//   /// Prompts the user to sign in with Google (Drive scope).
//   Future<GoogleSignInAccount?> signIn() async {
//     return await _googleSignIn.signIn();
//   }

//   /// Build an authenticated DriveApi client from the signed-in account
//   Future<drive.DriveApi?> getDriveApi(GoogleSignInAccount? account) async {
//     if (account == null) return null;
//     final authHeaders = await account.authHeaders;
//     final authenticateClient = GoogleAuthClient(authHeaders);
//     return drive.DriveApi(authenticateClient);
//   }

//   /// Upload a file to the user's Drive and return the uploaded file's ID.
//   Future<String?> uploadFile({
//     required drive.DriveApi driveApi,
//     required String filePath,
//     required String fileName,
//   }) async {
//     try {
//       // Create the file's metadata
//       var fileMetadata = drive.File();
//       fileMetadata.name = fileName;
//       // e.g., place it in a specific folder:
//       // fileMetadata.parents = ["<FOLDER_ID>"];

//       // Read the file content
//       var fileStream = http.ByteStream((await http.MultipartFile.fromPath('', filePath)).finalize());
//       var length = await File(filePath).length();

//       // Create Drive Media
//       var media = drive.Media(fileStream, length);

//       // Upload
//       drive.File response = await driveApi.files.create(
//         fileMetadata,
//         uploadMedia: media,
//       );

//       return response.id; // The file ID in Drive
//     } catch (e) {
//       print('Error uploading to Drive: $e');
//       return null;
//     }
//   }

//   /// Make the file publicly readable. Returns the webContentLink if needed.
//   Future<void> makeFilePublic(drive.DriveApi driveApi, String fileId) async {
//     try {
//       await driveApi.permissions.create(
//         drive.Permission(
//           role: 'reader',
//           type: 'anyone',
//         ),
//         fileId,
//       );
//       print('File is now public');
//     } catch (e) {
//       print('Error setting file public: $e');
//     }
//   }

//   /// Get a direct download link from the file ID, if it's public
//   Future<drive.File?> getFileInfo(drive.DriveApi driveApi, String fileId) async {
//     try {
//       final drive.File file = await driveApi.files.get(
//         fileId,
//         $fields: 'id, name, webContentLink, webViewLink',
//       );
//       return file; 
//     } catch (e) {
//       print('Error getting file info: $e');
//       return null; 
//     }
//   }

// }
