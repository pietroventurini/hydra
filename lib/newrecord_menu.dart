import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewRecordMenu extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _NewRecordMenuState();
}
  
class _NewRecordMenuState extends State<NewRecordMenu> {
  double _amount = 200;
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TextEditingController dateInputCtrl = TextEditingController(); 
  TextEditingController timeInputCtrl = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    dateInputCtrl.text = DateFormat.MMMd().format(selectedDate);
    timeInputCtrl.text = DateFormat.Hm().format(selectedDate);
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2019, 1),
      lastDate: DateTime(2100)
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dateInputCtrl.text = DateFormat.MMMd().format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        timeInputCtrl.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.cancel),
            ),
          ),
          Center(
            child: Column(
              children: [
                Row(
                  children: [
                    DateTimeContainer(
                      child: TextFormField(
                        controller: dateInputCtrl,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          icon: const Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.black,
                          ),
                          hintText: "Date",
                          border: InputBorder.none,
                        ),
                        onTap:() {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          _selectDate(context);
                        },
                      ),
                    ),
                    DateTimeContainer(
                      child: TextFormField(
                        controller: timeInputCtrl,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          icon: const Icon(
                            Icons.access_time_rounded,
                            color: Colors.black,
                          ),
                          hintText: "Time",
                          border: InputBorder.none,
                        ),
                        onTap:() {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          _selectTime(context);
                        }
                      ),
                    ),         
                  ],
                ),
                Text(
                  _amount.toInt().toString() + " ml",
                  style: Theme.of(context).textTheme.headline5
                ),
                Slider(
                  value: _amount,
                  min: 0,
                  max: 1000,
                  onChanged: (double value) { 
                    setState(() => _amount = value);
                  },
                ),
              ],
            ),
          ),
        ]
        ),
    );
  }
}

class DateTimeContainer extends StatelessWidget {
  const DateTimeContainer({Key? key, this.child}) : super(key: key);
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width * 0.38,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(29),
        border: Border.all(color: Colors.black87)
      ),
      child: child,
    );
  }
}