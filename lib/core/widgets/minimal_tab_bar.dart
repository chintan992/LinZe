import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/constants.dart';

class MinimalTabBar extends StatefulWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const MinimalTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<MinimalTabBar> createState() => _MinimalTabBarState();
}

class _MinimalTabBarState extends State<MinimalTabBar> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _indicatorAnimation;
  final Map<int, AnimationController> _tabScaleControllers = {};
  int _previousIndex = 0;
  final List<GlobalKey> _tabKeys = [];
  late ScrollController _scrollController;
  
  // Store the indicator's position and width
  double _indicatorLeft = 0.0;
  double _indicatorWidth = 0.0;
  
  // Variables to store animation start and end positions
  double _startLeft = 0.0;
  double _endLeft = 0.0;
  double _startWidth = 0.0;
  double _endWidth = 0.0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    // Initialize the indicator animation in initState so it's always available
    _indicatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    
    _scrollController = ScrollController();
    
    // Initialize tab keys
    _tabKeys.addAll(List.generate(widget.tabs.length, (index) => GlobalKey()));
    
    // Initialize scale controllers for each tab
    for (int i = 0; i < widget.tabs.length; i++) {
      _tabScaleControllers[i] = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
    }
    
    // Initialize the previous index to the selected index
    _previousIndex = widget.selectedIndex;
    
    // Add a single animation listener
    _animationController.addListener(() {
      final animationValue = _indicatorAnimation.value;
      setState(() {
        _indicatorLeft = _startLeft + (_endLeft - _startLeft) * animationValue;
        _indicatorWidth = _startWidth + (_endWidth - _startWidth) * animationValue;
      });
    });
    
    // Initialize the indicator's position and width for the initial selected tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndicatorForTab(widget.selectedIndex);
    });
  }

  @override
  void didUpdateWidget(MinimalTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle tab length change
    if (oldWidget.tabs.length != widget.tabs.length) {
      // Dispose of old controllers
      for (final controller in _tabScaleControllers.values) {
        controller.dispose();
      }
      _tabScaleControllers.clear();
      
      // Create new controllers
      _tabKeys.clear();
      _tabKeys.addAll(List.generate(widget.tabs.length, (index) => GlobalKey()));
      
      for (int i = 0; i < widget.tabs.length; i++) {
        _tabScaleControllers[i] = AnimationController(
          duration: const Duration(milliseconds: 200),
          vsync: this,
        );
      }
      
      // After regenerating _tabKeys and scale controllers, schedule a post-frame callback 
      // to measure the current selectedIndex tab and update indicator metrics
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateIndicatorForTab(widget.selectedIndex);
      });
    }
    
    // Handle selected index change for animation
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      
      // Calculate the positions and dimensions for the animation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final prevTabKey = _tabKeys[_previousIndex];
        final newTabKey = _tabKeys[widget.selectedIndex];
        
        final prevRenderBox = prevTabKey.currentContext?.findRenderObject() as RenderBox?;
        final newRenderBox = newTabKey.currentContext?.findRenderObject() as RenderBox?;
        
        if (prevRenderBox != null && newRenderBox != null) {
          final prevTabOffset = prevRenderBox.localToGlobal(Offset.zero);
          final newTabOffset = newRenderBox.localToGlobal(Offset.zero);
          final listViewRenderBox = _tabKeys[0].currentContext?.findRenderObject() as RenderBox?;
          final listViewOffset = listViewRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
          
          // Calculate positions relative to the list view
          _startLeft = prevTabOffset.dx - listViewOffset.dx;
          _endLeft = newTabOffset.dx - listViewOffset.dx;
          
          // Calculate widths
          _startWidth = prevRenderBox.size.width;
          _endWidth = newRenderBox.size.width;
          
          // Set the immediate indicator state to the starting values with setState
          // so the animation starts from the correct position
          setState(() {
            _indicatorLeft = _startLeft;
            _indicatorWidth = _startWidth;
          });
          
          // Reset the animation controller value and start the animation
          _animationController.value = 0.0;
          _animationController.forward();
        }
      });
    }
  }

  void _updateIndicatorForTab(int tabIndex) {
    if (tabIndex >= 0 && tabIndex < _tabKeys.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final tabKey = _tabKeys[tabIndex];
        final tabRenderBox = tabKey.currentContext?.findRenderObject() as RenderBox?;
        final listViewRenderBox = _tabKeys[0].currentContext?.findRenderObject() as RenderBox?;
        
        if (tabRenderBox != null && listViewRenderBox != null) {
          final tabOffset = tabRenderBox.localToGlobal(Offset.zero);
          final listViewOffset = listViewRenderBox.localToGlobal(Offset.zero);
          
          final left = tabOffset.dx - listViewOffset.dx;
          final width = tabRenderBox.size.width;
          
          setState(() {
            _indicatorLeft = left;
            _indicatorWidth = width;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    for (final controller in _tabScaleControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.tabs.length,
              itemBuilder: (context, index) {
                bool isSelected = index == widget.selectedIndex;
                return _buildTab(index, isSelected);
              },
            ),
            // Single animated indicator positioned at the bottom of the tab row
            Positioned(
              bottom: 0,
              left: _indicatorLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: _indicatorWidth,
                height: 3,
                decoration: BoxDecoration(
                  color: primaryColor, // Using the purple primary color as per brand
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, bool isSelected) {
    return AnimatedBuilder(
      animation: _tabScaleControllers[index]!, // Listen to the specific tab's controller
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (details) {
            // Scale up when pressed
            _tabScaleControllers[index]!.forward();
          },
          onTapUp: (details) {
            // Return to normal scale when released
            _tabScaleControllers[index]!.reverse();
            if (index != widget.selectedIndex) {
              widget.onTabSelected(index);
              
              // Auto-scroll to reveal the selected tab
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final RenderBox? renderBox = 
                    _tabKeys[index].currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  if (_tabKeys[index].currentContext != null) {
                    Scrollable.ensureVisible(
                      _tabKeys[index].currentContext!,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: 0.5, // Center the tab in view
                      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
                    );
                  }
                }
              });
            }
          },
          onTapCancel: () {
            // Return to normal scale when tap is cancelled
            _tabScaleControllers[index]!.reverse();
          },
          child: Transform.scale(
            scale: 1.0 + (_tabScaleControllers[index]!.value * 0.02), // Scale from 1.0 to 1.02
            child: Container(
              key: _tabKeys[index], // Assign the key to the container
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Semantics(
                selected: isSelected,
                label: widget.tabs[index],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.tabs[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? Colors.white : textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8), // Space for indicator
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}