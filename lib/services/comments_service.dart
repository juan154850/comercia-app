import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getComments(
      List<dynamic> commentRefs) async {
    List<Map<String, dynamic>> comments = [];
    for (var ref in commentRefs) {
      try {
        DocumentSnapshot<Map<String, dynamic>> commentSnapshot =
            await _firestore.doc(ref.path).get();

        if (commentSnapshot.exists) {
          Map<String, dynamic> commentData = commentSnapshot.data()!;

          // Obtener datos del usuario que creó el comentario
          DocumentSnapshot<Map<String, dynamic>> userSnapshot =
              await _firestore.doc(commentData['createdBy'].path).get();

          if (userSnapshot.exists) {
            commentData['user'] = userSnapshot.data();
          }

          comments.add(commentData);
        }
      } catch (e) {
        print('Error al obtener comentario: $e');
      }
    }
    return comments;
  }
}
