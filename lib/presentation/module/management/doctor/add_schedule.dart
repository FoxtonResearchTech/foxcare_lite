import 'package:flutter/material.dart';

class AddDoctorSchedule extends StatefulWidget {
  const AddDoctorSchedule({super.key});

  @override
  State<AddDoctorSchedule> createState() => _AddDoctorScheduleState();
}

class _AddDoctorScheduleState extends State<AddDoctorSchedule> {
  String? selectedDoctor;
  String? selectedSpecification;
  String? selectedCounter;
  TimeOfDay? opTime;
  TimeOfDay? outTime;

  final List<String> doctors = ['Dr. Smith', 'Dr. John', 'Dr. Rose'];
  final List<String> specifications = ['Cardiologist', 'Dentist', 'Neurologist'];
  final List<String> counterValues = List.generate(11, (index) => index.toString());

  Future<void> _selectTime(BuildContext context, bool isOpTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isOpTime) {
          opTime = picked;
        } else {
          outTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Management'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffaccbee), Color(0xffe7f0fd),],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 8),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Add Doctor Schedule',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Doctor',
                  border: OutlineInputBorder(),
                ),
                value: selectedDoctor,
                items: doctors.map((doctor) {
                  return DropdownMenuItem<String>(
                    value: doctor,
                    child: Text(doctor, style: const TextStyle(fontSize: 18)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedDoctor = value),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Specification',
                  border: OutlineInputBorder(),
                ),
                value: selectedSpecification,
                items: specifications.map((spec) {
                  return DropdownMenuItem<String>(
                    value: spec,
                    child: Text(spec, style: const TextStyle(fontSize: 18)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedSpecification = value),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _selectTime(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 10,
                      shadowColor: Colors.greenAccent,
                    ),
                    child: Text(opTime == null ? 'Select OP Time In' : opTime!.format(context), style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectTime(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 10,
                      shadowColor: Colors.redAccent,
                    ),
                    child: Text(outTime == null ? 'Select OP Time Out' : outTime!.format(context), style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _selectTime(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 10,
                      shadowColor: Colors.greenAccent,
                    ),
                    child: Text(opTime == null ? 'Select OP Time In' : opTime!.format(context), style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectTime(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 10,
                      shadowColor: Colors.redAccent,
                    ),
                    child: Text(outTime == null ? 'Select OP Time Out' : outTime!.format(context), style: const TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Counter',
                  border: OutlineInputBorder(),
                ),
                value: selectedCounter,
                items: counterValues.map((count) {
                  return DropdownMenuItem<String>(
                    value: count,
                    child: Text(count, style: const TextStyle(fontSize: 18)),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedCounter = value),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 10,
                  ),
                  child: const Text('Create Schedule', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


