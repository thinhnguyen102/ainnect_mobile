import 'package:flutter/material.dart';
import 'dart:async';
import '../models/suggestion_models.dart';
import '../services/suggestion_service.dart';
import '../utils/url_helper.dart';

Future<Map<String, String>>? _suggestionAvatarHeaders;

Widget _buildSuggestionAvatar(
  String? imageUrl,
  IconData placeholder, {
  double radius = 20,
}) {
  final fixedUrl = UrlHelper.fixImageUrl(imageUrl);
  if (fixedUrl == null) {
    return CircleAvatar(
      radius: radius,
      child: Icon(placeholder),
    );
  }
  _suggestionAvatarHeaders ??= UrlHelper.getHeaders();
  return FutureBuilder<Map<String, String>>(
    future: _suggestionAvatarHeaders,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return CircleAvatar(
          radius: radius,
          child: Icon(placeholder),
        );
      }
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(
          fixedUrl,
          headers: snapshot.data,
        ),
      );
    },
  );
}

class SchoolSuggestionField extends StatefulWidget {
  final String? initialValue;
  final Function(String schoolName, String? imageUrl) onSelected;
  final String token;
  final ValueChanged<String>? onChanged;

  const SchoolSuggestionField({
    Key? key,
    this.initialValue,
    required this.onSelected,
    required this.token,
    this.onChanged,
  }) : super(key: key);

  @override
  State<SchoolSuggestionField> createState() => _SchoolSuggestionFieldState();
}

class _SchoolSuggestionFieldState extends State<SchoolSuggestionField> {
  final TextEditingController _controller = TextEditingController();
  final SuggestionService _suggestionService = SuggestionService();
  List<SchoolSuggestion> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final suggestions = await _suggestionService.suggestSchools(widget.token, query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Trường học',
            hintText: 'Nhập tên trường học...',
            prefixIcon: const Icon(Icons.school, color: Color(0xFF1E88E5)),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
            ),
          ),
          onChanged: (value) {
            _onSearchChanged(value);
            widget.onChanged?.call(value);
          },
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  leading: _buildSuggestionAvatar(
                    suggestion.imageUrl,
                    Icons.school,
                  ),
                  title: Text(suggestion.schoolName),
                  subtitle: Text('${suggestion.count} người đã học'),
                  onTap: () {
                    _controller.text = suggestion.schoolName;
                    widget.onSelected(suggestion.schoolName, suggestion.imageUrl);
                    widget.onChanged?.call(suggestion.schoolName);
                    setState(() {
                      _suggestions = [];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class CompanySuggestionField extends StatefulWidget {
  final String? initialValue;
  final Function(String companyName, String? imageUrl) onSelected;
  final String token;
  final ValueChanged<String>? onChanged;

  const CompanySuggestionField({
    Key? key,
    this.initialValue,
    required this.onSelected,
    required this.token,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CompanySuggestionField> createState() => _CompanySuggestionFieldState();
}

class _CompanySuggestionFieldState extends State<CompanySuggestionField> {
  final TextEditingController _controller = TextEditingController();
  final SuggestionService _suggestionService = SuggestionService();
  List<CompanySuggestion> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final suggestions = await _suggestionService.suggestCompanies(widget.token, query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Công ty',
            hintText: 'Nhập tên công ty...',
            prefixIcon: const Icon(Icons.business, color: Color(0xFF1E88E5)),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
            ),
          ),
          onChanged: (value) {
            _onSearchChanged(value);
            widget.onChanged?.call(value);
          },
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  leading: _buildSuggestionAvatar(
                    suggestion.imageUrl,
                    Icons.business,
                  ),
                  title: Text(suggestion.companyName),
                  subtitle: Text('${suggestion.count} người đã làm việc'),
                  onTap: () {
                    _controller.text = suggestion.companyName;
                    widget.onSelected(suggestion.companyName, suggestion.imageUrl);
                    widget.onChanged?.call(suggestion.companyName);
                    setState(() {
                      _suggestions = [];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class InterestSuggestionField extends StatefulWidget {
  final String? initialValue;
  final Function(String name, String? imageUrl) onSelected;
  final String token;
  final ValueChanged<String>? onChanged;

  const InterestSuggestionField({
    Key? key,
    this.initialValue,
    required this.onSelected,
    required this.token,
    this.onChanged,
  }) : super(key: key);

  @override
  State<InterestSuggestionField> createState() => _InterestSuggestionFieldState();
}

class _InterestSuggestionFieldState extends State<InterestSuggestionField> {
  final TextEditingController _controller = TextEditingController();
  final SuggestionService _suggestionService = SuggestionService();
  List<InterestSuggestion> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final suggestions = await _suggestionService.suggestInterests(widget.token, query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Sở thích',
            hintText: 'Nhập sở thích...',
            prefixIcon: const Icon(Icons.interests, color: Color(0xFF1E88E5)),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
            ),
          ),
          onChanged: (value) {
            _onSearchChanged(value);
            widget.onChanged?.call(value);
          },
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  leading: _buildSuggestionAvatar(
                    suggestion.imageUrl,
                    Icons.interests,
                  ),
                  title: Text(suggestion.name),
                  subtitle: Text('${suggestion.count} người quan tâm'),
                  onTap: () {
                    _controller.text = suggestion.name;
                    widget.onSelected(suggestion.name, suggestion.imageUrl);
                    widget.onChanged?.call(suggestion.name);
                    setState(() {
                      _suggestions = [];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class LocationSuggestionField extends StatefulWidget {
  final String? initialValue;
  final Function(String locationName, String? imageUrl) onSelected;
  final String token;
  final ValueChanged<String>? onChanged;

  const LocationSuggestionField({
    Key? key,
    this.initialValue,
    required this.onSelected,
    required this.token,
    this.onChanged,
  }) : super(key: key);

  @override
  State<LocationSuggestionField> createState() => _LocationSuggestionFieldState();
}

class _LocationSuggestionFieldState extends State<LocationSuggestionField> {
  final TextEditingController _controller = TextEditingController();
  final SuggestionService _suggestionService = SuggestionService();
  List<LocationSuggestion> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final suggestions = await _suggestionService.suggestLocations(widget.token, query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Vị trí',
            hintText: 'Nhập tên địa điểm...',
            prefixIcon: const Icon(Icons.location_on, color: Color(0xFF1E88E5)),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
            ),
          ),
          onChanged: (value) {
            _onSearchChanged(value);
            widget.onChanged?.call(value);
          },
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  leading: _buildSuggestionAvatar(
                    suggestion.imageUrl,
                    Icons.location_on,
                  ),
                  title: Text(suggestion.locationName),
                  subtitle: Text('${suggestion.count} lượt check-in'),
                  onTap: () {
                    _controller.text = suggestion.locationName;
                    widget.onSelected(suggestion.locationName, suggestion.imageUrl);
                    widget.onChanged?.call(suggestion.locationName);
                    setState(() {
                      _suggestions = [];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
