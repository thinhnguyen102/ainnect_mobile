import 'package:flutter/material.dart';
import 'dart:async';
import '../models/suggestion_models.dart';
import '../services/suggestion_service.dart';

class SchoolSuggestionField extends StatefulWidget {
  final String? initialValue;
  final Function(String schoolName, String? imageUrl) onSelected;
  final String token;

  const SchoolSuggestionField({
    Key? key,
    this.initialValue,
    required this.onSelected,
    required this.token,
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
  String? _selectedImageUrl;

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
          onChanged: _onSearchChanged,
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
                  leading: suggestion.imageUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(suggestion.imageUrl!),
                          radius: 20,
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.school),
                          radius: 20,
                        ),
                  title: Text(suggestion.schoolName),
                  subtitle: Text('${suggestion.count} người đã học'),
                  onTap: () {
                    _controller.text = suggestion.schoolName;
                    _selectedImageUrl = suggestion.imageUrl;
                    widget.onSelected(suggestion.schoolName, suggestion.imageUrl);
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

  const CompanySuggestionField({
    Key? key,
    this.initialValue,
    required this.onSelected,
    required this.token,
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
  String? _selectedImageUrl;

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
          onChanged: _onSearchChanged,
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
                  leading: suggestion.imageUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(suggestion.imageUrl!),
                          radius: 20,
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.business),
                          radius: 20,
                        ),
                  title: Text(suggestion.companyName),
                  subtitle: Text('${suggestion.count} người đã làm việc'),
                  onTap: () {
                    _controller.text = suggestion.companyName;
                    _selectedImageUrl = suggestion.imageUrl;
                    widget.onSelected(suggestion.companyName, suggestion.imageUrl);
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

  const InterestSuggestionField({
    Key? key,
    this.initialValue,
    required this.onSelected,
    required this.token,
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
  String? _selectedImageUrl;

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
          onChanged: _onSearchChanged,
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
                  leading: suggestion.imageUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(suggestion.imageUrl!),
                          radius: 20,
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.interests),
                          radius: 20,
                        ),
                  title: Text(suggestion.name),
                  subtitle: Text('${suggestion.count} người quan tâm'),
                  onTap: () {
                    _controller.text = suggestion.name;
                    _selectedImageUrl = suggestion.imageUrl;
                    widget.onSelected(suggestion.name, suggestion.imageUrl);
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

  const LocationSuggestionField({
    Key? key,
    this.initialValue,
    required this.onSelected,
    required this.token,
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
  String? _selectedImageUrl;

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
          onChanged: _onSearchChanged,
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
                  leading: suggestion.imageUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(suggestion.imageUrl!),
                          radius: 20,
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.location_on),
                          radius: 20,
                        ),
                  title: Text(suggestion.locationName),
                  subtitle: Text('${suggestion.count} lượt check-in'),
                  onTap: () {
                    _controller.text = suggestion.locationName;
                    _selectedImageUrl = suggestion.imageUrl;
                    widget.onSelected(suggestion.locationName, suggestion.imageUrl);
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
