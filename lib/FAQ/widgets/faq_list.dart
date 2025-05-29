import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ieee_website/Themes/website_colors.dart';
import 'faq_states.dart';
import 'faq_buttons.dart';
import 'dart:ui';

class FAQList extends StatelessWidget {
  final bool isSmallScreen;
  final String currentDocId;
  final Function(String, String, String) onEdit;
  final Function(String) onDelete;
  final Function(int, int, List<QueryDocumentSnapshot>) onReorder;

  const FAQList({
    Key? key,
    required this.isSmallScreen,
    required this.currentDocId,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FAQ List Header - Enhanced
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: WebsiteColors.primaryBlueColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: WebsiteColors.primaryBlueColor,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: WebsiteColors.primaryBlueColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.quiz_outlined,
                        color: WebsiteColors.whiteColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Frequently Asked Questions",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: WebsiteColors.darkBlueColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Drag items to reorder",
                            style: TextStyle(
                              fontSize: 12,
                              color: WebsiteColors.descGreyColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // FAQ List - Enhanced
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('faq')
                .orderBy('order')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return buildErrorState();
              }

              if (!snapshot.hasData) {
                return buildLoadingState();
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return buildEmptyState();
              }

              return Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.transparent,
                ),
                child: ReorderableListView.builder(
                  key: Key('faq_list_${docs.length}'), // Unique key for list
                  itemCount: docs.length,
                  onReorder: (oldIndex, newIndex) =>
                      onReorder(oldIndex, newIndex, docs),
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  proxyDecorator: (child, index, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (BuildContext context, Widget? child) {
                        final double animValue =
                        Curves.easeInOut.transform(animation.value);
                        final double elevation = lerpDouble(1, 6, animValue) ?? 1;
                        final double scale = lerpDouble(1, 1.02, animValue) ?? 1;
                        return Transform.scale(
                          scale: scale,
                          child: Card(
                            elevation: elevation,
                            shadowColor: WebsiteColors.primaryBlueColor
                                .withOpacity(0.3),
                            child: child,
                          ),
                        );
                      },
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final question = data['question'] ?? '';
                    final answer = data['answer'] ?? '';
                    final bool isCurrentEditingItem = currentDocId == docId;

                    return Container(
                      key: Key(docId),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isCurrentEditingItem
                            ? Border.all(
                            color: WebsiteColors.primaryBlueColor, width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isCurrentEditingItem
                                    ? WebsiteColors.primaryBlueColor
                                    : WebsiteColors.primaryBlueColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      "${index + 1}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isCurrentEditingItem
                                            ? WebsiteColors.whiteColor
                                            : WebsiteColors.primaryBlueColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Icon(
                                      Icons.drag_indicator,
                                      color: isCurrentEditingItem
                                          ? WebsiteColors.whiteColor
                                          .withOpacity(0.7)
                                          : WebsiteColors.primaryBlueColor
                                          .withOpacity(0.5),
                                      size: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                question,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: isCurrentEditingItem
                                      ? WebsiteColors.primaryBlueColor
                                      : WebsiteColors.darkGreyColor,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: WebsiteColors.primaryBlueColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.expand_more,
                                color: WebsiteColors.primaryBlueColor,
                                size: 18,
                              ),
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                                16, 0, 16, 16),
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            expandedCrossAxisAlignment:
                            CrossAxisAlignment.start,
                            backgroundColor: Colors.grey.shade50,
                            collapsedBackgroundColor:
                            WebsiteColors.whiteColor,
                            iconColor: WebsiteColors.primaryBlueColor,
                            collapsedIconColor: WebsiteColors.primaryBlueColor,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: WebsiteColors.whiteColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: WebsiteColors.primaryBlueColor
                                                .withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                            Icons.lightbulb_outline,
                                            size: 14,
                                            color:
                                            WebsiteColors.primaryBlueColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Answer",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color:
                                            WebsiteColors.primaryBlueColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      answer,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: WebsiteColors.darkGreyColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      softWrap: true,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.end,
                                      children: [
                                        ActionButton(
                                          icon: Icons.edit_outlined,
                                          label: "Edit",
                                          color:
                                          WebsiteColors.primaryBlueColor,
                                          onPressed: () =>
                                              onEdit(docId, question, answer),
                                        ),
                                        const SizedBox(width: 8),
                                        ActionButton(
                                          icon: Icons.delete_outlined,
                                          label: "Delete",
                                          color: WebsiteColors.redColor,
                                          onPressed: () => onDelete(docId),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}