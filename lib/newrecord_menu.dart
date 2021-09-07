import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:hydra/model/record_model.dart';

class NewRecordMenu extends StatefulWidget {
  final int id;
  const NewRecordMenu(this.id);

  @override
  State<StatefulWidget> createState() => _NewRecordMenuState();
}
  
class _NewRecordMenuState extends State<NewRecordMenu> {
  String? _title;
  double _amount = 200;
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TextEditingController dateInputCtrl = TextEditingController(); 
  TextEditingController timeInputCtrl = TextEditingController(); 

  @override
  void initState() {
    super.initState();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.cancel),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: TextFormField(
                        decoration: InputDecoration(
                          icon: const Icon(
                            Icons.text_fields,
                            color: Colors.black,
                          ),
                          hintText: "Choose a Title",
                        ),
                      ),
                    ),
                  ),
                  Row(
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO post record to server
                        // ...
                        final Record record = new Record(
                          id: widget.id,
                          timestamp: new DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedTime.hour,
                            _selectedTime.minute),
                          quantity: _amount.toInt(),
                        );
                        
                        Navigator.pop(context, record);
                      }
                    },
                    child: const Text("Create"),
                  )
                ],
              ),
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