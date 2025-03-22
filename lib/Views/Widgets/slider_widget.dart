import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/auth_model.dart';
import '../../ViewModels/auth_provider.dart';

class MySlider extends StatelessWidget {
  final Function(int) onItemSelected;

  MySlider({
    super.key,
    required this.onItemSelected,
  });

  final List<IconData> icons = [Icons.home, Icons.person, Icons.settings];
  final List<String> texts = ["Home", "Profile", "Settings"];

  @override
  Widget build(BuildContext context) {
    return Selector<AuthenticateProvider, AuthenticateModel>(
      builder: (context, user, _) {
        return _buildDrawer(
          context,
          user.email,
          user.role,
          user.name ?? "NA",
        );
      },
      selector: (_, provider) => provider.authUser,
    );
  }

  Widget _buildDrawer(BuildContext context, String userEmail, String userRole,
      String userName) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 18.0),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
              minRadius: 32,
              maxRadius: 52,
              backgroundImage: AssetImage('assets/images/employees.png')),
          SizedBox(height: size.height * 0.025),
          Text("Name: $userName",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Email: $userEmail",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Role: $userRole",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: size.height * 0.025),
          Expanded(
            child: ListView.builder(
              itemCount: icons.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, i) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                leading: Icon(icons[i], color: Colors.white, size: 30),
                title: Text(texts[i],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                onTap: () => onItemSelected(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
