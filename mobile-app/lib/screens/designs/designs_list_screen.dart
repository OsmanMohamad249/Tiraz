// lib/screens/designs/designs_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/design.dart';
import '../../services/design_service.dart';
import '../../widgets/design_card.dart';

class DesignsListScreen extends ConsumerStatefulWidget {
  @override
  _DesignsListScreenState createState() => _DesignsListScreenState();
}

class _DesignsListScreenState extends ConsumerState<DesignsListScreen> {
  final DesignService _designService = DesignService();
  List<Design> _designs = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadDesigns();
  }
  
  Future<void> _loadDesigns() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    final result = await _designService.getDesigns();
    
    if (result['success']) {
      setState(() {
        _designs = result['designs'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['error'];
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Designs'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDesigns,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDesigns,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _designs.isEmpty
                  ? Center(child: Text('No designs available'))
                  : RefreshIndicator(
                      onRefresh: _loadDesigns,
                      child: GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _designs.length,
                        itemBuilder: (context, index) {
                          return DesignCard(design: _designs[index]);
                        },
                      ),
                    ),
    );
  }
}
