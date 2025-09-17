import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatefulWidget {
  final List<File> selectedImages;
  final Function(List<File>) onImagesChanged;
  final int maxImages;
  final String title;

  const ImagePickerWidget({
    Key? key,
    required this.selectedImages,
    required this.onImagesChanged,
    this.maxImages = 5,
    this.title = "Images",
  }) : super(key: key);

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImagesFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null) {
        List<File> newImages = images.map((xfile) => File(xfile.path)).toList();
        
        // Check if adding new images would exceed the limit
        if (widget.selectedImages.length + newImages.length > widget.maxImages) {
          int allowedCount = widget.maxImages - widget.selectedImages.length;
          if (allowedCount > 0) {
            newImages = newImages.take(allowedCount).toList();
            _showSnackBar('Only $allowedCount more images allowed. Selected first $allowedCount images.');
          } else {
            _showSnackBar('Maximum ${widget.maxImages} images allowed');
            return;
          }
        }
        
        List<File> updatedImages = [...widget.selectedImages, ...newImages];
        widget.onImagesChanged(updatedImages);
      }
    } catch (e) {
      _showSnackBar('Error picking images: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      if (widget.selectedImages.length >= widget.maxImages) {
        _showSnackBar('Maximum ${widget.maxImages} images allowed');
        return;
      }

      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        List<File> updatedImages = [...widget.selectedImages, File(image.path)];
        widget.onImagesChanged(updatedImages);
      }
    } catch (e) {
      _showSnackBar('Error taking photo: $e');
    }
  }

  void _removeImage(int index) {
    List<File> updatedImages = [...widget.selectedImages];
    updatedImages.removeAt(index);
    widget.onImagesChanged(updatedImages);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.photo_library, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: widget.selectedImages.length < widget.maxImages
                      ? _showImageSourceOptions
                      : null,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Add up to ${widget.maxImages} images from gallery or camera",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            if (widget.selectedImages.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.photo, size: 40, color: Colors.grey.shade500),
                      const SizedBox(height: 8),
                      Text(
                        "No images selected",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tap 'Add Image' to select photos",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.selectedImages.asMap().entries.map((entry) {
                    int index = entry.key;
                    File image = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            
            if (widget.selectedImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "${widget.selectedImages.length}/${widget.maxImages} images selected",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
