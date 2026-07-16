import 'package:flutter/material.dart';
import 'package:task_manager/controller/auth_controller.dart';
import 'package:task_manager/screens/login_screen.dart';
import '../screens/update_profile_screen.dart';
import '../utils/app_colors.dart';

class TmAppbar extends StatelessWidget implements PreferredSize {
  const TmAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      title: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UpdateProfileScreen()),
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                'https://cdn.ostad.app/public/upload/2023-01-21T05-49-24.235Z-Group2252.png',
              ),
            ),

            SizedBox(width: 10),
            Column(
              children: [
                Text(
                  '${AuthController.userData!.firstName} ${AuthController.userData!.lastName}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(color: Colors.white),
                ),
                Text(
                  AuthController.userData!.email.toString(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),

      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            await AuthController.clearUserData();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  @override
  // TODO: implement child
  Widget get child => throw UnimplementedError();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
