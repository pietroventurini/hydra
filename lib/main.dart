import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hydra/account.dart';
import 'package:hydra/database/repository.dart';
import 'package:hydra/home.dart';
import 'package:hydra/screens/login/login.dart';
import 'package:hydra/model/records.dart';
import 'package:hydra/services/authentication_service.dart';
import 'package:hydra/settings.dart';
import 'package:hydra/stats.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.subscribeToTopic('test');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
          
        ),
        StreamProvider(
          create: (context) => context.read<AuthenticationService>().authStateChanges, 
          initialData: null
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xfff3f7fb),
          fontFamily: 'Avenir',
          /*sliderTheme: SliderThemeData(
            activeTrackColor: const Color.fromARGB(255, 62, 87, 117),
            thumbColor: const Color.fromARGB(255, 62, 87, 117)
          ),*/
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600, color: const Color.fromARGB(255, 62, 87, 117)),
            headline2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 62, 87, 117)),
            headline3: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: const Color.fromARGB(255, 62, 87, 117)),
            headline4: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, color: const Color.fromARGB(255, 171, 186, 214)),
            bodyText1: TextStyle(color: const Color.fromARGB(255, 62, 87, 117)),
            bodyText2: TextStyle(fontSize: 16.0, color: const Color.fromARGB(255, 62, 87, 117)),
          ),
        ),
        restorationScopeId: 'root',
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {

  AuthenticationWrapper();

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser == null) {
      return LoginPage();
    }

    // check if it is a new user
    return FutureBuilder<bool>(
      future: Repository(FirebaseFirestore.instance).isUserAlreadyRegistered(),
      builder: (context, snapshot) {
        return MainPage(  
            title: 'Flutter Demo Home Page',
            restorationId: 'bottom_navigation_labels_demo'
          );
      }
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key? key, this.title, required this.restorationId})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String? title;
  final String restorationId;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with RestorationMixin {
  final RestorableInt _navIndex = RestorableInt(0);

  @override
  String? get restorationId => widget.restorationId;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("Token: " + token!);
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
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

    final icons = List<IconData>.unmodifiable([
      Icons.home_rounded,
      Icons.show_chart_rounded,
      Icons.account_circle_rounded,
    ]);

    final _labels = List<String>.unmodifiable(["Home", "Stats", "Account"]);

    final _screens = List<Widget>.unmodifiable([
      FutureBuilder(
        future: Repository(FirebaseFirestore.instance).initializeDailyHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamProvider<Records>(
              create: (_) => Repository(FirebaseFirestore.instance).todaysRecordsStream(),
              initialData: Records(
                date: DateTime.now(),
                records: <Record>[]
              ),
              child: HomeTab(),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }),
      StatsTab(),
      AccountTab(),
    ]);

    return Scaffold(
      body: _screens[_navIndex.value],
      backgroundColor: const Color.fromARGB(255, 236, 243, 248),
      bottomNavigationBar: MobileNavBar(
        activeIndex: _navIndex.value,
        icons: icons,
        labels: _labels,
        onTap: _onItemTapped,
      ),
    );
  }
}         

class MobileNavBar extends StatelessWidget {
  MobileNavBar({
    required this.activeIndex,
    required this.icons,
    required this.labels,
    required this.onTap})
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
      selectedItemColor: const Color.fromARGB(255, 62, 87, 117),
      unselectedItemColor: const Color.fromARGB(180, 62, 87, 117),
      //type: BottomNavigationBarType.shifting,
      backgroundColor: const Color.fromARGB(255, 236, 243, 248),
      
      items: <BottomNavigationBarItem>[
        for (var i = 0; i < icons.length; i++)
          BottomNavigationBarItem(icon: Icon(icons[i]), label: labels[i])
      ],
      currentIndex: activeIndex,
      onTap: onTap,
    );
  }
}
