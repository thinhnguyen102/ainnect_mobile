import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/messaging_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/friendship_provider.dart';
import 'services/websocket_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Handle Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => MessagingProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => FriendshipProvider()),
      ],
      child: MaterialApp(
        title: 'AiConnect',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final WebSocketService _wsService = WebSocketService();
  bool _hasConnectedWebSocket = false;
  
  @override
  void initState() {
    super.initState();
    print('🔷 AuthWrapper initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
    });
  }

  @override
  void dispose() {
    print('🔷 AuthWrapper dispose - disconnecting WebSocket');
    _wsService.disconnect();
    super.dispose();
  }

  void _handleAuthStateChange(AuthState state) {
    print('🔷 Auth state changed to: $state');
    
    if (state == AuthState.authenticated && !_hasConnectedWebSocket) {
      print('🔷 User authenticated, connecting WebSocket...');
      _hasConnectedWebSocket = true;
      // Delay to ensure UI is built
      Future.delayed(const Duration(milliseconds: 500), () {
        print('🔷 Delayed callback executing, mounted=$mounted');
        if (mounted) {
          print('🔷 Calling _wsService.connect()...');
          try {
            _wsService.connect();
            print('🔷 _wsService.connect() called successfully');
          } catch (e, stackTrace) {
            print('🔷 ERROR calling _wsService.connect(): $e');
            print('🔷 Stack trace: $stackTrace');
          }
        } else {
          print('🔷 Widget not mounted, skipping connect');
        }
      });
    } else if (state != AuthState.authenticated && _hasConnectedWebSocket) {
      print('🔷 User not authenticated, disconnecting WebSocket...');
      _hasConnectedWebSocket = false;
      _wsService.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Handle WebSocket connection based on auth state
        _handleAuthStateChange(authProvider.state);
        
        switch (authProvider.state) {
          case AuthState.initial:
          case AuthState.loading:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          case AuthState.authenticated:
            return const MainScreen();
          case AuthState.unauthenticated:
          case AuthState.error:
            return const LoginScreen();
        }
      },
    );
  }
}
