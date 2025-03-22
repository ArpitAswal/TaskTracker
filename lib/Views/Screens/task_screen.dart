import 'package:flutter/material.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:popup_card/popup_card.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/Utils/helpers/dynamic_context_widgets.dart';
import 'package:todo_task/Views/Screens/profile_screen.dart';
import 'package:todo_task/Views/Screens/setting_screen.dart';

import '../../ViewModels/setting_provider.dart';
import '../../ViewModels/todo_provider.dart';
import '../Widgets/slider_widget.dart';
import '../Widgets/task_card_widget.dart';
import '../Widgets/task_tabview_widget.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<SliderDrawerState> _dKey = GlobalKey<SliderDrawerState>();
  late TabController _tabCnt;
  late TodoProvider _outerProvider;
  late ValueNotifier<int> _selectedIndex;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _tabCnt = TabController(length: 2, vsync: this);
    _outerProvider = context.read<TodoProvider>();
    _selectedIndex = ValueNotifier(0);
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward(from: 0.0);
    _tabCnt.addListener(() {
      _outerProvider.setIndex(_tabCnt.index);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        DynamicContextWidgets.init(context);
        _initializePermissions();
      }
    });
  }

  Future<void> _initializePermissions() async {
    final prov = context.read<SettingsProvider>();
    // Wait for widget to be fully mounted
    if (mounted) {
      await _outerProvider.checkAndRequestPermissions(prov);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabCnt.dispose();
    _fadeController.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return TaskTabView(tabController: _tabCnt);
      case 1:
        return const ProfileScreen();
      case 2:
        return const SettingScreen();
      default:
        return const Center(child: Text("Invalid Selection"));
    }
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return "TaskTracker Screen";
      case 1:
        return "Profile Screen";
      case 2:
        return "Settings Screen";
      default:
        return "Default Screen";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, index, child){
          if(index == 0){
            return PopupItemLauncher(
                tag: "TaskCard",
                popUp: PopUpItem(
                    tag: "TaskCard",
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: EdgeInsets.zero,
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: context.read<SettingsProvider>().isDarkMode
                            ? BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2.0)
                            : BorderSide.none),
                    child: TaskCardWidget((newTodo) {
                      _outerProvider.addTodo(newTodo);
                    }, null, popupTitle: "Add New Task")),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.add_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 32,
                  ),
                ));
          } else{
           return const SizedBox.shrink();
          }
        },
      ),
      body: SliderDrawer(
        isDraggable: false,
        key: _dKey,
        animationDuration: 600,
        sliderOpenSize: MediaQuery.of(context).size.width * 0.75,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: SliderAppBar(
            config: SliderAppBarConfig(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Center(
              child: ValueListenableBuilder(
            valueListenable: _selectedIndex,
            builder: (context, index, child) {
              return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(_getTitle(index),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor),
                      overflow: TextOverflow.ellipsis));
            },
          )),
          drawerIconColor: Theme.of(context).primaryColor,
        )),
        slider: MySlider(
          onItemSelected: (index) {
            _selectedIndex.value = index;
            _dKey.currentState!.closeSlider();
          },
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: _selectedIndex,
          builder: (context, index, child) {
            return FadeTransition(
                opacity: _fadeAnimation, child: _getScreen(index));
          },
        ),
      ),
    );
  }
}
