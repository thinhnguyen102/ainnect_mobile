import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'providers/auth_provider.dart';
import 'providers/messaging_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/friendship_provider.dart';
import 'services/websocket_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/home_screen.dart';
import 'widgets/environment_banner.dart';
import 'utils/server_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Print environment info
  print('🌍 Environment: ${ServerConfig.currentEnvironment}');
  print('🔗 API URL: ${ServerConfig.baseUrl}');
  
  // Set timeago Vietnamese locale
  timeago.setLocaleMessages('vi', timeago.ViMessages());
  
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
            seedColor: const Color(0xFF1E88E5),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
        ),
        builder: (context, child) {
          // Wrap with environment banner in non-production environments
          return EnvironmentBanner(child: child ?? const SizedBox.shrink());
        },
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
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
            return const HomeScreen(showGuestBanner: true);
        }
      },
    );
  }
}
