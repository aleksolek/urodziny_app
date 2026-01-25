import 'package:flutter/material.dart';
import 'calendar.dart';
import 'add_birthday.dart';
import 'choose_person.dart';
import 'edit_event.dart';
import 'style.dart';

const CalendarRoute = '/';
const AddBirthdayRoute = '/add_birthday';
const ChoosePersonRoute = '/choose_person';
const EditEventRoute = '/edit_event';

class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: _routes(),
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        appBarTheme: AppBarTheme(titleTextStyle: AppBarTextStyle),
        textTheme: TextTheme(
          titleLarge: TitleTextStyle,
          bodyMedium: Body1TextStyle,
        ),
      ),
    );
  }

  RouteFactory _routes() {
    return (settings) {
      Widget screen;
      switch (settings.name) {
        case CalendarRoute:
          screen = Calendar();
          break;
        case AddBirthdayRoute:
          final DateTime day = settings.arguments as DateTime;
          screen = AddBirthday(day);
          break;
        case ChoosePersonRoute:
          screen = ChoosePerson();
          break;
        case EditEventRoute:
          final Map<String, dynamic> args =
              settings.arguments as Map<String, dynamic>;
          screen = EditEvent(args["day"], args["index"]);
          break;
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }
}
