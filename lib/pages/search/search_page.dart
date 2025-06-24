import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../themes/colors/colors.dart';
import '../../controllers/search_controller.dart' as mysearch;
import '../../widgets/search_components.dart';
import 'components/search_bar.dart' as search_bar;
import 'components/search_discover_section.dart';
import 'components/search_history_section.dart';
import 'components/search_results_section.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  late mysearch.SearchController _controller;
  AnimationController? _searchBarController;
  Animation<double>? _searchBarAnimation;

  @override
  void initState() {
    super.initState();
    _controller = mysearch.SearchController();

    try {
      _searchBarController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );

      _searchBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _searchBarController!, curve: Curves.easeInOut),
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _searchBarController?.forward();
        }
      });
    } catch (e) {
      print('Lỗi khởi tạo animation: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchBarController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<mysearch.SearchController>.value(
      value: _controller,
      child: Consumer<mysearch.SearchController>(
        builder: (context, controller, _) {
          return PopScope(
            canPop:
                !controller.showHistory &&
                !controller.showSuggestions &&
                controller.currentQuery.isEmpty &&
                !controller.searchFocus.hasFocus,
            onPopInvoked: (didPop) {
              if (didPop) return;

              if (controller.showHistory) {
                controller.hideHistory();
              } else if (controller.showSuggestions) {
                controller.hideSuggestions();
              } else if (controller.searchFocus.hasFocus) {
                controller.searchFocus.unfocus();
                FocusScope.of(context).unfocus();
              } else if (controller.currentQuery.isNotEmpty) {
                controller.clearSearch();
              }
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: _buildAppBar(controller),
              body: Stack(
                children: [
                  _buildMainContent(controller),
                  if (controller.showSuggestions)
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: SearchSuggestionsList(controller: controller),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(mysearch.SearchController controller) {
    return AppBar(
        leading: Container(),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
    );
  }

  Widget _buildMainContent(mysearch.SearchController controller) {
    return Column(
      children: [
        search_bar.CustomSearchBar(
          controller: controller,
          readOnly: false,
          animation: _searchBarAnimation,
          onTap: () {
            // TextField tự động focus khi tap, không cần logic phức tạp
          },
        ),
        if (controller.hasResults || controller.currentQuery.isNotEmpty) ...[
          const SizedBox(height: 12),
          SearchFilterChips(controller: controller),
        ],
        Expanded(child: _buildContentArea(controller)),
      ],
    );
  }

  Widget _buildContentArea(mysearch.SearchController controller) {
    if (controller.isLoading) {
      return const SearchLoadingIndicator();
    }

    if (controller.showHistory) {
      return SearchHistorySection(controller: controller);
    }

    if (controller.hasResults) {
      return SearchResultsSection(controller: controller);
    }

    if (controller.currentQuery.isNotEmpty && !controller.hasResults) {
      return SearchEmptyState(
        query: controller.currentQuery,
        filter: controller.currentFilter.name,
        errorMessage: controller.errorMessage,
        hasError: controller.hasError,
        onRetry: controller.retrySearch,
      );
    }

    return SearchDiscoverSection(controller: controller);
  }
}
