import 'package:flutter/material.dart';
import '../../data/services/social_api_service.dart';

const Color _sapphire = Color(0xFF0D6078);
const Color _linen = Color(0xFFF2EBE1);
const Color _indigo = Color(0xFF022F40);

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final SocialApiService _apiService = SocialApiService();
  bool _isLoading = false;
  
  String _selectedCategory = 'VICTORY';
  String _selectedMood = 'HAPPY';

  final List<String> categories = ['VICTORY', 'STRUGGLE', 'ADVICE', 'GRATITUDE', 'QUESTION'];
  final Map<String, String> moods = {
    'HAPPY': '😊', 
    'NEUTRAL': '😐', 
    'ANXIOUS': '😰', 
    'STRONG': '💪', 
    'PRAYING': '🙏'
  };

  void _submitPost() async {
    if (_contentController.text.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      await _apiService.createPost(_contentController.text, _selectedCategory, _selectedMood);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post submitted for moderation!'))
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _linen,
      appBar: AppBar(
        title: const Text('Share Your Journey', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _linen,
        foregroundColor: _indigo,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _sapphire))
                : const Text('Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _sapphire)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Selector
            const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _indigo)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) => ChoiceChip(
                label: Text(cat, style: TextStyle(
                  color: _selectedCategory == cat ? Colors.white : _sapphire,
                  fontWeight: FontWeight.bold,
                )),
                selected: _selectedCategory == cat,
                selectedColor: _sapphire,
                backgroundColor: _sapphire.withOpacity(0.1),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedCategory = cat);
                },
              )).toList(),
            ),
            const SizedBox(height: 20),
            
            // Mood Selector
            const Text('How are you feeling?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _indigo)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: moods.entries.map((entry) => GestureDetector(
                onTap: () => setState(() => _selectedMood = entry.key),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedMood == entry.key ? _sapphire.withOpacity(0.2) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedMood == entry.key ? _sapphire : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(entry.value, style: const TextStyle(fontSize: 28)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            
            // Content Input
            TextField(
              controller: _contentController,
              maxLines: 10,
              maxLength: 2000,
              style: const TextStyle(color: _indigo, fontSize: 16),
              decoration: InputDecoration(
                hintText: "What's on your mind? Everything here is anonymous and safe.",
                hintStyle: TextStyle(color: _indigo.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
