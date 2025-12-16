import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/theme/app_colors.dart';

class ReviewInputSheet extends StatefulWidget {
  final double initialRating;
  final String initialComment;
  final Function(double rating, String comment) onSubmit;

  const ReviewInputSheet({
    super.key,
    this.initialRating = 0,
    this.initialComment = '',
    required this.onSubmit,
  });

  @override
  State<ReviewInputSheet> createState() => _ReviewInputSheetState();
}

class _ReviewInputSheetState extends State<ReviewInputSheet> {
  late double _rating;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Write a Review',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(20),
          Center(
            child: RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
          ),
          const Gap(20),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const Gap(20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_rating > 0 && _commentController.text.isNotEmpty) {
                  widget.onSubmit(_rating, _commentController.text);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Submit Review'),
            ),
          ),
          const Gap(20),
        ],
      ),
    );
  }
}
