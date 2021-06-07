import 'package:flutter/material.dart';
import 'package:hydra/account.dart';
import 'package:hydra/home.dart';
import 'package:hydra/stats.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xfff3f7fb)),
      restorationScopeId: 'root',
      home: MainPage(
          title: 'Flutter Demo Home Page',
          restorationId: 'bottom_navigation_labels_demo'),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title, @required this.restorationId})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String restorationId;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with RestorationMixin {
  final RestorableInt _navIndex = RestorableInt(0);

  @override
  String get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket oldBucket, bool initialRestore) {
    registerForRestoration(_navIndex, 'bottom_navigation_tab_index');
  }

  @override
  void dispose() {
    _navIndex.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _currentIndex without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _navIndex.value = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    final icons = List<IconData>.unmodifiable([
      Icons.home_rounded,
      Icons.show_chart_rounded,
      Icons.account_circle_rounded,
    ]);

    final labels = List<String>.unmodifiable(["Home", "Stats", "Account"]);

    final _screens = List<Widget>.unmodifiable([
      HomeTab(),
      StatsTab(),
      AccountTab(),
    ]);

    return Scaffold(
        body: _screens[_navIndex.value],
        bottomNavigationBar: MobileNavBar(
          activeIndex: _navIndex.value,
          icons: icons,
          labels: labels,
          onTap: _onItemTapped,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openNewRecordMenu(),
          tooltip: "New check-in",
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked);
  }

  void _openNewRecordMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height * 0.85,
          child: Center(
            child: Column(
              children: [],
            ),
          ),
        );
      },
    );
  }
}

class MobileNavBar extends StatelessWidget {
  MobileNavBar(
      {@required this.activeIndex,
      @required this.icons,
      @required this.labels,
      @required this.onTap})
      : assert(activeIndex < icons.length),
        assert(icons.length == labels.length);

  final int activeIndex;
  final List<IconData> icons;
  final List<String> labels;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showUnselectedLabels: false,
      items: <BottomNavigationBarItem>[
        for (var i = 0; i < icons.length; i++)
          BottomNavigationBarItem(icon: Icon(icons[i]), label: labels[i])
      ],
      currentIndex: activeIndex,
      onTap: onTap,
    );
  }
}
