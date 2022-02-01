import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:hydra/model/records.dart';

class NewRecordMenu extends StatefulWidget {
  final String id;
  final bool edit;
  final Record? record;
  const NewRecordMenu({
    required this.id, 
    required this.edit, 
    this.record
  });

  @override
  State<StatefulWidget> createState() => _NewRecordMenuState();
}
  
class _NewRecordMenuState extends State<NewRecordMenu> {
  String? _title;
  late double _amount;
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  TextEditingController dateInputCtrl = TextEditingController(); 
  TextEditingController timeInputCtrl = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    _title = widget.edit ? widget.record!.title : null;
    _amount = widget.edit ? widget.record!.quantity.toDouble() : 200;
    _selectedDate = widget.edit ? widget.record!.timestamp : DateTime.now();
    _selectedTime = widget.edit ? TimeOfDay.fromDateTime(widget.record!.timestamp) : TimeOfDay.now();
    dateInputCtrl.text = DateFormat.MMMd().format(_selectedDate);
    timeInputCtrl.text = DateFormat.Hm().format(_selectedDate);
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2019, 1),
      lastDate: DateTime(2100)
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dateInputCtrl.text = DateFormat.MMMd().format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        timeInputCtrl.text = picked.format(context);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.cancel),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Text(
                      widget.edit ? "Edit note" : "Create a new note",
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontSize: 26,
                        color: const Color.fromARGB(255, 62, 87, 117), //Colors.black87,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                      initialValue: widget.edit ? widget.record!.title : null,
                      decoration: InputDecoration(
                        icon: const Icon(
                          Icons.text_fields,
                          color: Colors.black,
                        ),
                        hintText: "Title",
                      ),
                    onChanged: (title) => _title = title,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 80),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
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
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Select a valid time";
                            }
                            return null;
                          },
                        ),
                      ),         
                    ],
                  ),
                ),
                Text(
                  _amount.toInt().toString() + " ml",
                  style: Theme.of(context).textTheme.headline5
                ),
                Slider(
                  value: _amount,
                  min: 0,
                  max: 1000,
                  divisions: 200,
                  onChanged: (double value) { 
                    setState(() => _amount = value);
                  },
                ),
                SizedBox(
                  height: 100,
                ),
                ElevatedButton( 
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 62, 87, 117),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    elevation: 2,
                    shape: StadiumBorder(),
                    minimumSize: Size(130,50),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final Record newRecord = new Record(
                        id: widget.id,
                        timestamp: new DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          _selectedTime.hour,
                          _selectedTime.minute),
                        quantity: _amount.toInt(),
                        title: _title,
                      );
                      
                      Navigator.pop(context, newRecord);
                    }
                  },
                  child: Text(widget.edit ? "Edit" : "Create"),
                )
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
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width * 0.36,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(29),
        border: Border.all(color: Colors.black87)
      ),
      child: child,
    );
  }
}