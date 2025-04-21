import 'package:flutter/material.dart';

// Assuming these colors are defined in a separate file (e.g., colors.dart)
// Replace with your actual color definitions if needed
class AppColors {
  static const Color backgroundColor = Colors.white; // Example color
  static const Color iconColor = Colors.black; // Example color
  static const Color textColor = Colors.black; // Example color
  static const Color sideMenuItemBackgroundColor = Colors.grey; // Example color
}

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundColor,
      child: ListView(
        children: <Widget>[
          // Drawer Header
          Container(
            padding: const EdgeInsets.only(top: 10, left: 8, bottom: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/user.png'),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Minhajul Hasan",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.iconColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 45,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 2, left: 8, bottom: 2),
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(251, 181, 0, 1.000),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                "4.0",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Icon(
                                Icons.star_rate_rounded,
                                size: 14,
                                color: AppColors.textColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 10),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 20,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
          // Drawer Body
          _buildDrawerItem(
            icon: Icons.account_balance_wallet,
            title: "Wallet",
            onTap: () {
              print("Wallet tapped");
              // Add navigation or logic here
            },
          ),
          _buildDrawerItem(
            icon: Icons.history,
            title: "Your Ride",
            onTap: () {
              print("Your Ride tapped");
              // Add navigation or logic here
            },
          ),
          _buildDrawerItem(
            icon: Icons.notifications,
            title: "Notification",
            onTap: () {
              print("Notification tapped");
              // Add navigation or logic here
            },
          ),
          _buildDrawerItem(
            icon: Icons.currency_rupee,
            title: "Transaction",
            onTap: () {
              print("Transaction tapped");
              // Add navigation or logic here
            },
          ),
          ListTile(
            title: const Text(
              "Settings and Preferences",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.iconColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () {
              print("Settings and Preferences tapped");
              // Add navigation or logic here
            },
          ),
          _buildDrawerItem(
            icon: Icons.edit_document,
            title: "Help Center",
            onTap: () {
              print("Help Center tapped");
              // Add navigation or logic here
            },
          ),
          _buildDrawerItem(
            icon: Icons.flag,
            title: "Report a Bug",
            onTap: () {
              print("Report a Bug tapped");
              // Add navigation or logic here
            },
          ),
          // Drawer Footer (Logout)
          ListTile(
            title: Container(
              padding: const EdgeInsets.only(top: 120, left: 0, bottom: 0),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.logout,
                      size: 22,
                      color: Color.fromARGB(255, 232, 72, 72),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      print("Log out tapped");
                      // Add logout logic here (e.g., navigate to SignInScreen)
                      // Example:
                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                    },
                    child: const Text(
                      "Log out",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 232, 72, 72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // Helper method to build consistent drawer items
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Container(
        padding: const EdgeInsets.only(top: 4, left: 0, bottom: 4),
        decoration: const BoxDecoration(
          color: AppColors.sideMenuItemBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.iconColor,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.iconColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }
}