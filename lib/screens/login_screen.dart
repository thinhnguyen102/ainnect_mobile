import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/server_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serverIpController = TextEditingController();
  final _serverPortController = TextEditingController();
  bool _obscurePassword = true;
  bool _showServerConfig = false;

  @override
  void initState() {
    super.initState();
    _loadServerConfig();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _serverIpController.dispose();
    _serverPortController.dispose();
    super.dispose();
  }

  Future<void> _loadServerConfig() async {
    final ip = await ServerConfig.getServerIp();
    final port = await ServerConfig.getServerPort();
    _serverIpController.text = ip;
    _serverPortController.text = port.toString();
    Constants.baseUrl = ServerConfig.getBaseUrl(ip, port);
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Lưu server config và cập nhật baseUrl
      final ip = _serverIpController.text.trim();
      final port = int.tryParse(_serverPortController.text.trim()) ?? ServerConfig.defaultServerPort;
      await ServerConfig.saveServerConfig(ip, port);
      Constants.baseUrl = ServerConfig.getBaseUrl(ip, port);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Color(0xFF6366F1),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Chào mừng trở lại',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đăng nhập để tiếp tục sử dụng ainnect',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Vui lòng nhập email hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return ElevatedButton(
                      onPressed: authProvider.state == AuthState.loading
                          ? null
                          : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: authProvider.state == AuthState.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showServerConfig = !_showServerConfig;
                        });
                      },
                      icon: Icon(
                        _showServerConfig ? Icons.settings_outlined : Icons.settings,
                        color: const Color(0xFF6366F1),
                      ),
                      label: Text(
                        _showServerConfig ? 'Ẩn cấu hình' : 'Cấu hình server',
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showServerConfig) ...[
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: TextFormField(
                              controller: _serverIpController,
                              decoration: const InputDecoration(
                                labelText: 'Server IP',
                                prefixIcon: Icon(Icons.dns_outlined),
                                border: OutlineInputBorder(),
                                helperText: 'Mặc định: 10.0.2.2',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập địa chỉ server';
                                }
                                // Kiểm tra IP hợp lệ
                                final parts = value.split('.');
                                if (parts.length != 4) {
                                  return 'Địa chỉ IP không hợp lệ';
                                }
                                for (final part in parts) {
                                  final number = int.tryParse(part);
                                  if (number == null || number < 0 || number > 255) {
                                    return 'Địa chỉ IP không hợp lệ';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _serverPortController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Port',
                                prefixIcon: Icon(Icons.numbers),
                                border: OutlineInputBorder(),
                                helperText: '8080',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nhập port';
                                }
                                final port = int.tryParse(value);
                                if (port == null || port <= 0 || port > 65535) {
                                  return 'Port không hợp lệ';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final ip = _serverIpController.text.trim();
                                final port = int.tryParse(_serverPortController.text.trim()) ?? ServerConfig.defaultServerPort;
                                await ServerConfig.saveServerConfig(ip, port);
                                Constants.baseUrl = ServerConfig.getBaseUrl(ip, port);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã lưu cấu hình server'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.save_outlined,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                            label: const Text(
                              'Lưu cấu hình',
                              style: TextStyle(
                                color: Color(0xFF6366F1),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () async {
                              await ServerConfig.saveServerConfig(
                                ServerConfig.defaultServerIp,
                                ServerConfig.defaultServerPort,
                              );
                              _serverIpController.text = ServerConfig.defaultServerIp;
                              _serverPortController.text = ServerConfig.defaultServerPort.toString();
                              Constants.baseUrl = ServerConfig.getBaseUrl(
                                ServerConfig.defaultServerIp,
                                ServerConfig.defaultServerPort,
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã khôi phục cấu hình mặc định'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.restore_outlined,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                            label: const Text(
                              'Khôi phục mặc định',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    "Chưa có tài khoản? Đăng ký ngay",
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
