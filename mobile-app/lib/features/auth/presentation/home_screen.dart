// lib/features/auth/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'login_screen.dart';
import '../../../screens/designs/designs_list_screen.dart';
import '../../../screens/measurements/measurements_list_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          authState.maybeWhen(
            authenticated: (_) => IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
                // Stay on home screen, state change will trigger UI update to guest view
              },
              tooltip: 'Logout',
            ),
            orElse: () => TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text('Login', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Center(
        child: authState.when(
          initial: () => CircularProgressIndicator(),
          loading: () => CircularProgressIndicator(),
          authenticated: (user) => Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Colors.green,
                ),
                SizedBox(height: 24),
                Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Logged in as:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  user.displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 40),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.style),
                      label: Text('Browse Designs'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => DesignsListScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.straighten),
                      label: Text('Measurements'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MeasurementsListScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                      onPressed: () async {
                        await ref.read(authStateProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          unauthenticated: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront, size: 80, color: Colors.blue),
                SizedBox(height: 24),
                Text(
                  'Welcome to Qeyafa',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  'Browse our latest designs',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 40),
                ElevatedButton.icon(
                  icon: Icon(Icons.style),
                  label: Text('Browse Designs'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DesignsListScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.upload_file),
                  label: Text('Upload Measurements'),
                  onPressed: () {
                    // Redirect to login since upload requires auth
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please login to upload measurements')),
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          error: (message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error: $message',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
