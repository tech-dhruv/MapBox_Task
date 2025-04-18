
import 'package:flutter/material.dart';

import '../data/repository/user_repo.dart';

class UserProvider extends ChangeNotifier {
  final UserRepo userRepo;
  UserProvider(this.userRepo);

}
