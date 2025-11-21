import 'package:flutter/material.dart';
import '../utils/server_config.dart';

/// Widget to display current environment banner (only in debug mode)
/// Shows environment name and API URL at the top of the screen
class EnvironmentBanner extends StatelessWidget {
  final Widget child;

  const EnvironmentBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode and non-production environments
    final shouldShowBanner = ServerConfig.currentEnvironment != 'production';

    if (!shouldShowBanner) {
      return child;
    }

    return Banner(
      message: _getEnvironmentLabel(),
      location: BannerLocation.topEnd,
      color: _getEnvironmentColor(),
      child: Stack(
        children: [
          child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: _getEnvironmentColor().withOpacity(0.9),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: SafeArea(
                bottom: false,
                child: Text(
                  '${_getEnvironmentLabel()} - ${ServerConfig.baseUrl}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEnvironmentLabel() {
    switch (ServerConfig.currentEnvironment.toLowerCase()) {
      case 'staging':
      case 'stg':
        return 'STAGING';
      case 'development':
      case 'dev':
        return 'DEV';
      case 'production':
      case 'prod':
        return 'PROD';
      default:
        return ServerConfig.currentEnvironment.toUpperCase();
    }
  }

  Color _getEnvironmentColor() {
    switch (ServerConfig.currentEnvironment.toLowerCase()) {
      case 'staging':
      case 'stg':
        return Colors.orange;
      case 'development':
      case 'dev':
        return Colors.green;
      case 'production':
      case 'prod':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
