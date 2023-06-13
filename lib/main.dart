import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_teste/Models/users.dart';
import 'package:menu_teste/pages/addClass.dart';
import 'package:menu_teste/app.dart';
import 'package:menu_teste/pages/addAttendance.dart';
import 'package:menu_teste/pages/classReport.dart';
import 'package:menu_teste/pages/welcome.dart';
import 'package:menu_teste/services/activity_detector.dart';
import 'package:menu_teste/services/auth_logout_service.dart';
import 'package:menu_teste/services/auth_service.dart';
import 'package:menu_teste/services/config.dart';
import 'package:menu_teste/firebase/classService.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:provider/provider.dart';
import 'pages/approveAttendance.dart';
import 'pages/qrcode.dart';

void main() async{
  await initConfiguration();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => ClassService()),
        ChangeNotifierProvider(create: (context) => AutoLogoutService()),
      ],
      child: appisqrac()
    ),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of.
  @override
  Widget build(BuildContext context) {
    return   
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Docente',
      theme: ThemeData(
        primaryColor: primaryColor,
        canvasColor: canvasColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  
  @override
  _HomePageState createState() => _HomePageState();
}
const primaryColor = Color.fromARGB(255, 5, 5, 5);
const canvasColor = Color.fromARGB(255, 217, 217, 223);
const scaffoldBackgroundColor = Colors.grey;


class _HomePageState extends State<HomePage> {
  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();
  List<Users> _teachersList = [];
  String name = "";
  bool genre = true;
  String lastName = "";
  String emailTeacher="";

  
  @override
  void initState() {
    super.initState();

    getTeacherName();
  }


    getTeacherName() async {

          emailTeacher = AuthService().getEmail();
          var collection = FirebaseFirestore.instance.collection("Users").where("email", isEqualTo: emailTeacher);
          List<Map<String, dynamic>> tempList =[];
    
          var data = await collection.get();
          data.docs.forEach((element) {
          tempList.add(element.data());
          if (element.data() != "NULL") {
            setState((){
              //name= element.data(). toString();
              _teachersList.add(Users.fromJson(element.data()));
              name = _teachersList[0].nameFirst.toString();
              lastName = _teachersList[0].nameLast.toString();
              if (_teachersList[0].genre.toString()=='M'){genre=true;}else{genre=false;}
            });
          }
          });
    }

  @override
  Widget build(BuildContext context) {
    
    return UserActivityDetector(
      child:SafeArea(
      child: Builder(
        builder: (context) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            key: _key,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(70.0),
              child:  
                AppBar(
                  backgroundColor: Color.fromARGB(255, 217, 217, 223),
                  leadingWidth: 100,
                  leading: 
                    Container(
                      //padding: const EdgeInsets.all(0.1),
                      child:  Image.asset('assets/images/IPC-PRETO.png', fit: BoxFit.cover)
                      ),
                  actions:[
                    
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:
                          (genre) 
                          ? [
                          Row(
                          children:[
                            Padding(
                              padding: EdgeInsets.all(2),
                              child:
                                Image.asset('assets/images/mUser.png',fit: BoxFit.cover, scale: 13,))]),
                          const SizedBox(width: 8),
                    Text(name+' '+lastName),
                    //Text('Sair');
                          ]:
                          [
                          Row(
                          children:[
                            Padding(
                              padding: const EdgeInsets.all(2),
                              child:
                                Image.asset('assets/images/fUser.png',fit: BoxFit.cover, scale: 16))]),    
                    SizedBox(width: 8),
                    Text(name+' '+lastName),
                    //Text('Sair'),
                          ],
                          
                ),
                IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => context.read<AuthService>().logoutUser(reason: "Manual"),
                    ),])
            ),
            drawer: SideBarXExample(controller: _controller,),
            body: Row(
              children: [
                if(!isSmallScreen) SideBarXExample(controller: _controller),
                Expanded(child: Center(child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context,child){
                    switch(_controller.selectedIndex){
                      case 0: _key.currentState?.closeDrawer();
                      return Welcome();
                      case 1: _key.currentState?.closeDrawer();
                      return QRCodeGenerator();
                      case 2: _key.currentState?.closeDrawer();
                      return ApproveAtt();
                      case 3: _key.currentState?.closeDrawer();
                      return ClassReport();
                      case 4: _key.currentState?.closeDrawer();
                      return AddClass();
                      case 5: _key.currentState?.closeDrawer();
                      return AddStudent();
                      
                      default:
                        return Center(
                          child: Text('Home',style: TextStyle(color: Colors.white,fontSize: 40),),
                        );
                    }
                  },
                ),))
              ],
            ),
            
          );
        }
      ),
    ));
  }
}

class SideBarXExample extends StatelessWidget {
  const SideBarXExample({Key? key, required SidebarXController controller}) : _controller = controller,super(key: key);
  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {

    return SidebarX(
      controller: _controller,
      theme:  const SidebarXTheme(
        decoration: BoxDecoration(
            color: canvasColor,
            //borderRadius: BorderRadius.only(topRight: Radius.circular(20),bottomRight: Radius.circular(20))
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        selectedTextStyle: const TextStyle(color: Colors.white),
      ),
      extendedTheme: const SidebarXTheme(
          width: 300,
      ),

      footerDivider: Divider(color:  Colors.white.withOpacity(0.8), height: 1),
      headerBuilder: (context,extended){
        return SizedBox(
          height: 100,
          //child: Image.asset('images/ipc.png'),
        );
      },

      items: const [
        SidebarXItem(icon: Icons.first_page, label: 'Infordocente'),
        SidebarXItem(icon: Icons.qr_code, label: 'Gerador QR'),
        SidebarXItem(icon: Icons.school, label: 'Aulas e vigilâncias'),
        SidebarXItem(icon: Icons.summarize, label: 'As minhas aulas'),
        SidebarXItem(icon: Icons.add, label: 'Adicionar aulas'),
        SidebarXItem(icon: Icons.add, label: 'Presença manual'),
      ],
    );
    
  }

  
}