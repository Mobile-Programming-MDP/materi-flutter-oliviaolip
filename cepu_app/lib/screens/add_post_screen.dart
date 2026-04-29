import 'package:flutter/material.dart';
import 'package:cepu_app/models/post.dart';
import 'package:cepu_app/services/post_service.dart';

class AddPostScreen extends StatefulWidget {
  final Post? initialPost;

  const AddPostScreen({
    super.key,
    this.initialPost,
  });

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _postService = PostService();

  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _imageController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.initialPost?.description ?? '');
    _categoryController =
        TextEditingController(text: widget.initialPost?.category ?? '');
    _imageController =
        TextEditingController(text: widget.initialPost?.image ?? '');
    _latitudeController = TextEditingController(
        text: widget.initialPost?.latitude.toString() ?? '');
    _longitudeController = TextEditingController(
        text: widget.initialPost?.longitude.toString() ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final post = Post(
        id: widget.initialPost?.id ?? '',
        image: _imageController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        createdAt: widget.initialPost?.createdAt ?? now,
        updatedAt: now,
        userId: widget.initialPost?.userId ?? 'user_id_placeholder',
        userFullname: widget.initialPost?.userFullname ?? 'User Name',
      );

      if (widget.initialPost != null) {
        // Update existing post
        await _postService.updatePost(widget.initialPost!.id, post);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );
      } else {
        // Create new post
        await _postService.createPost(post);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully')),
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialPost != null ? 'Edit Post' : 'Add New Post'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  border: OutlineInputBorder(),
                  hintText: 'Enter image URL',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Enter post description',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  hintText: 'Enter category',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                  hintText: 'Enter latitude',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter latitude';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                  hintText: 'Enter longitude',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter longitude';
                  }
                  try {
                    double.parse(value);
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.initialPost != null ? 'Update Post' : 'Create Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
