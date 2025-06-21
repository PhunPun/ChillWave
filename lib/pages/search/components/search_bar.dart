import 'package:flutter/material.dart';
import '../../../themes/colors/colors.dart';
import '../../../controllers/search_controller.dart' as mysearch;
import '../search_micro_page.dart';
import '../search_music_page.dart';

class CustomSearchBar extends StatelessWidget {
  final mysearch.SearchController controller;
  final bool readOnly;
  final Function() onTap;
  final Animation<double>? animation;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.readOnly,
    required this.onTap,
    this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (animation == null) {
      return _buildSearchBarContent(context);
    }

    return AnimatedBuilder(
      animation: animation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - animation!.value) * 50),
          child: Opacity(
            opacity: animation!.value,
            child: _buildSearchBarContent(context),
          ),
        );
      },
    );
  }

  Widget _buildSearchBarContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(MyColor.pr2),
            borderRadius: BorderRadius.circular(28),
            boxShadow:
                controller.searchFocus.hasFocus
                    ? [
                      BoxShadow(
                        color: const Color(MyColor.pr5).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            border: Border.all(
              color:
                  controller.searchFocus.hasFocus
                      ? const Color(MyColor.pr5)
                      : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  controller.isLoading ? Icons.hourglass_empty : Icons.search,
                  key: ValueKey(controller.isLoading),
                  color: const Color(MyColor.se4),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  readOnly: readOnly,
                  focusNode: controller.searchFocus,
                  controller: controller.searchController,
                  style: const TextStyle(fontSize: 16),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Tìm kiếm bài hát, nghệ sĩ, album...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Color(MyColor.grey),
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                  onChanged: controller.onSearchChanged,
                  onSubmitted: controller.onSearchSubmitted,
                ),
              ),
              if (controller.currentQuery.isNotEmpty) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: controller.clearSearch,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(MyColor.grey),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              _buildVoiceSearchButton(context),
              const SizedBox(width: 8),
              _buildMusicRecognitionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceSearchButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (context) => const SearchMicroPage()),
        );

        if (result != null && result.isNotEmpty) {
          controller.searchController.text = result;
          controller.onSearchSubmitted(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(MyColor.pr5),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.mic, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildMusicRecognitionButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (context) => const SearchMusicPage()),
        );

        if (result != null && result.isNotEmpty) {
          controller.searchController.text = result;
          controller.onSearchSubmitted(result);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color(MyColor.pr5),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.music_note, color: Colors.white, size: 20),
      ),
    );
  }
}
