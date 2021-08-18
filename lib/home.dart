import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var cardDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(.23),
          blurRadius: 30,
          offset: Offset(0, 10),
        )
      ],
    );

    var progressCard = Container(
      height: 180,
      margin: EdgeInsets.only(top: 24, left: 24, right: 24),
      decoration: cardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Today's progress",
                    style: TextStyle(
                      fontFamily: 'Avenir',
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "1200",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.black87,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: "/2000ml",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: 0.3,
                  strokeWidth: 10.0,
                  backgroundColor: Colors.black12,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    var newRecordTab = Container(
      margin: EdgeInsets.only(top: 20, left: 26, right: 26),
      decoration: cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Drink check-in",
                  style: TextStyle(
                    fontFamily: 'Avenir',
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 50,
                      width: 100,
                      child: TextFormField(
                        initialValue: "20:37",
                        decoration: InputDecoration(
                          icon: Icon(Icons.schedule_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );

    var historyTab = Expanded(
      child: Container(
        //color: Colors.white,
        margin: EdgeInsets.only(left: 26, top: 30),
        child: ListView.builder(
          reverse: true,
          itemCount: 15,
          itemBuilder: (BuildContext context, index) {
            return Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text("Time ${index + 1}"),
                  ),
                  Expanded(
                    flex: 8,
                    child: Container(
                      color: Colors.white,
                      height: 60,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          progressCard,
          //newRecordTab,
          historyTab,
        ],
      ),
    );
  }
}
