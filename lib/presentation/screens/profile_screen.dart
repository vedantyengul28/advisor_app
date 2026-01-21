// import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';
// import '../widgets/glass_container.dart';
// import 'login_screen.dart';
// import 'package:provider/provider.dart';
// import '../../data/services/auth_service.dart';
// import '../../data/services/history_service.dart';
// import 'orders_screen.dart';
// import '../../data/services/brands_service.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final auth = Provider.of<AuthService>(context);
//     final profile = auth.currentUserProfile;
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 // Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const SizedBox(width: 24), // Spacer for centering
//                     Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
//                     const Icon(Icons.settings, color: Colors.white),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // User Info Card
//                 GlassContainer(
//                   padding: const EdgeInsets.all(20),
//                   child: Row(
//                     children: [
//                       Stack(
//                         children: [
//                           const CircleAvatar(
//                              radius: 30,
//                              backgroundColor: Colors.grey,
//                              child: Icon(Icons.person, size: 40, color: Colors.white),
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: GestureDetector(
//                               onTap: () async {
//                                 final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
//                                 if (uid == null) return;
//                                 await HistoryService().logEvent(uid, 'profile_action', {'action': 'edit_avatar'});
//                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit profile coming soon')));
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: const BoxDecoration(
//                                   color: Colors.blue,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(Icons.edit, size: 12, color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(width: 16),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             profile?.name ?? 'User',
//                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                           ),
//                           Text(
//                             profile?.email ?? '',
//                             style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // Orders Button Link
//                 GlassContainer(
//                    onTap: () {
//                      Navigator.of(context).push(
//                        MaterialPageRoute(builder: (_) => const OrdersScreen()),
//                      );
//                    },
//                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                    child: const Row(
//                      children: [
//                        Icon(Icons.inventory_2_outlined),
//                        SizedBox(width: 16),
//                        Expanded(child: Text('Orders')),
//                        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
//                      ],
//                    ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Profile Details
//                 GlassContainer(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                        Text('MY PROFILE', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
//                        const Divider(color: Colors.white12, height: 24),
//                        _buildInfoRow('Mobile Number', profile?.mobile ?? '-'),
//                        _buildInfoRow('Gender', profile?.gender ?? '-'),
//                        _buildInfoRow('Occupation', profile?.occupation ?? '-'),
//                        _buildInfoRow('Desired Style', profile?.stylePreference ?? '-'),
//                        FutureBuilder<List<String>>(
//                          future: () async {
//                            final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
//                            if (uid == null) return const <String>[];
//                            return BrandsService().getUserBrandNames(uid);
//                          }(),
//                          builder: (context, snapshot) {
//                            final brandsText = snapshot.hasData && snapshot.data!.isNotEmpty
//                                ? snapshot.data!.join(', ')
//                                : (profile?.brands ?? '-');
//                            return _buildInfoRow('Brands', brandsText);
//                          },
//                        ),
//                        _buildInfoRow('Address', profile?.address ?? '-'),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Settings Links
//                 _buildMenuButton(context, 'Looksmart Tutorial', Icons.play_circle_outline),
//                 _buildMenuButton(context, 'About', Icons.info_outline),
                
//                 const SizedBox(height: 10),
//                 GlassContainer(
//                    onTap: () async {
//                      await Provider.of<AuthService>(context, listen: false).signOut();
//                      Navigator.of(context).pushReplacement(
//                        MaterialPageRoute(builder: (_) => const LoginScreen()),
//                      );
//                    },
//                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                    child: const Row(
//                      children: [
//                        Icon(Icons.logout),
//                        SizedBox(width: 16),
//                        Expanded(child: Text('LogOut')),
//                        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
//                      ],
//                    ),
//                 ),
                
//                 const SizedBox(height: 24),
//                 const Text('Version 0.1.1', style: TextStyle(color: Colors.white24)),
//                 const SizedBox(height: 80), // Bottom padding for nav bar
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: const TextStyle(color: Colors.white54),
//             ),
//           ),
//           const Text(': ', style: TextStyle(color: Colors.white54)),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMenuButton(BuildContext context, String title, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: GlassContainer(
//          onTap: () async {
//            final uid = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
//            if (uid == null) return;
//            await HistoryService().logEvent(uid, 'menu_click', {'title': title});
//            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title opened')));
//          },
//          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//          child: Row(
//            children: [
//              Icon(icon),
//              const SizedBox(width: 16),
//              Expanded(child: Text(title)),
//              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
//            ],
//          ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/constants/app_colors.dart';
import '../widgets/glass_container.dart';
import '../../data/services/history_service.dart';

import 'login_screen.dart';
import 'orders_screen.dart';

/// ===========================================================================
/// PROFILE SCREEN
/// ===========================================================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        Text(
                          'Profile',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // User Info Card
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey,
                                backgroundImage: data?['photoUrl'] != null
                                    ? NetworkImage(data!['photoUrl'])
                                    : null,
                                child: data?['photoUrl'] == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    if (user == null) return;
                                    await _pickAndUploadImage(
                                      context,
                                      user.uid,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data?['name'] ?? 'User',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  data?['email'] ?? '',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Orders
                    GlassContainer(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OrdersScreen(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.inventory_2_outlined),
                          SizedBox(width: 16),
                          Expanded(child: Text('Orders')),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile Details
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MY PROFILE',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Divider(color: Colors.white12, height: 24),
                          _info('Mobile', data?['mobile']),
                          _info('Gender', data?['gender']),
                          _info('Occupation', data?['occupation']),
                          _info('Style', data?['stylePreference']),
                          _info('Brands', data?['brands']),
                          _info('Address', data?['address']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    _menu(
                      context,
                      'Looksmart Tutorial',
                      Icons.play_circle_outline,
                    ),
                    _menu(context, 'About', Icons.info_outline),

                    const SizedBox(height: 10),

                    // Logout
                    GlassContainer(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 16),
                          Expanded(child: Text('LogOut')),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Version 0.1.1',
                      style: TextStyle(color: Colors.white24),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget _info(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.white54)),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _menu(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        onTap: () {
          if (title == 'About') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TutorialScreen()),
            );
          }
        },
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Expanded(child: Text(title)),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// IMAGE UPLOAD (FIREBASE STORAGE)
/// ===========================================================================
Future<void> _pickAndUploadImage(BuildContext context, String uid) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);

  if (picked == null) return;

  final ref = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');

  await ref.putFile(File(picked.path));
  final url = await ref.getDownloadURL();

  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'photoUrl': url,
  });

  await HistoryService().logEvent(uid, 'profile_action', {'avatar': 'updated'});

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('Profile image updated')));
}

/// ===========================================================================
/// EDIT PROFILE SCREEN
/// ===========================================================================
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _mobile = TextEditingController();
  final _gender = TextEditingController();
  final _occupation = TextEditingController();
  final _style = TextEditingController();
  final _brands = TextEditingController();
  final _address = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final d = doc.data();
    if (d != null) {
      _name.text = d['name'] ?? '';
      _mobile.text = d['mobile'] ?? '';
      _gender.text = d['gender'] ?? '';
      _occupation.text = d['occupation'] ?? '';
      _style.text = d['stylePreference'] ?? '';
      _brands.text = d['brands'] ?? '';
      _address.text = d['address'] ?? '';
    }
    setState(() {});
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': _name.text,
      'mobile': _mobile.text,
      'gender': _gender.text,
      'occupation': _occupation.text,
      'stylePreference': _style.text,
      'brands': _brands.text,
      'address': _address.text,
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field('Name', _name),
              _field('Mobile', _mobile),
              _field('Gender', _gender),
              _field('Occupation', _occupation),
              _field('Style Preference', _style),
              _field('Brands', _brands),
              _field('Address', _address, max: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int max = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        maxLines: max,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// ABOUT US
/// ===========================================================================
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Looksmart')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Center(child: Icon(Icons.auto_awesome, size: 80)),
            SizedBox(height: 20),
            Text(
              'Looksmart',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Looksmart is a smart fashion assistant that helps users '
              'discover their personal style using intelligent insights.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                'Version 0.1.1',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// EXTRA SCREENS
/// ===========================================================================
class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Tutorial')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings')));
}
