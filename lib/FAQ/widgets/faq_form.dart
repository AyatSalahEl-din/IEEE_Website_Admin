import 'package:flutter/material.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'faq_buttons.dart';

class FAQForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController questionController;
  final TextEditingController answerController;
  final bool isEditing;
  final String currentDocId;
  final VoidCallback onAddOrUpdate;
  final VoidCallback onCancel;

  const FAQForm({
    Key? key,
    required this.formKey,
    required this.questionController,
    required this.answerController,
    required this.isEditing,
    required this.currentDocId,
    required this.onAddOrUpdate,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: WebsiteColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Form Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    WebsiteColors.primaryBlueColor,
                    WebsiteColors.primaryBlueColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: WebsiteColors.whiteColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_note : Icons.add_circle_outline,
                      color: WebsiteColors.whiteColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? "Edit Question" : "Add New Question",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: WebsiteColors.whiteColor,
                          ),
                        ),
                        Text(
                          isEditing
                              ? "Update the existing FAQ item"
                              : "Create a new FAQ entry",
                          style: TextStyle(
                            fontSize: 13,
                            color: WebsiteColors.whiteColor.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Field
                    _buildFormField(
                      label: "Question",
                      hint: "Enter your question here...",
                      controller: questionController,
                      icon: Icons.help_outline,
                      maxLines: 1,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a question';
                        }
                        if (value.trim().length < 5) {
                          return 'Question must be at least 5 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Answer Field
                    _buildFormField(
                      label: "Answer",
                      hint: "Provide a detailed answer...",
                      controller: answerController,
                      icon: Icons.lightbulb_outline,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an answer';
                        }
                        if (value.trim().length < 10) {
                          return 'Answer must be at least 10 characters long';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Form Actions
                    Row(
                      children: [
                        if (isEditing) ...[
                          Expanded(
                            child: SecondaryButton(
                              label: "Cancel",
                              icon: Icons.cancel_outlined,
                              onPressed: onCancel,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: PrimaryButton(
                            label: isEditing ? "Update Question" : "Add Question",
                            icon: isEditing
                                ? Icons.save_outlined
                                : Icons.add_circle_outline,
                            onPressed: onAddOrUpdate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required int maxLines,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: WebsiteColors.darkGreyColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: WebsiteColors.descGreyColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: WebsiteColors.primaryBlueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: WebsiteColors.primaryBlueColor,
                size: 18,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WebsiteColors.primaryBlueColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WebsiteColors.redColor,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: WebsiteColors.redColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            errorStyle: TextStyle(
              color: WebsiteColors.redColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}