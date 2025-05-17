import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String fullName = '';
  int? age;
  String gender = 'Female';
  String phone = '';
  String city = '';
  bool isVictim = true;
  bool wantsContact = true;
  String preferredContact = 'Email';
  String story = '';

  final List<String> genders = ['Female', 'Male', 'Other', 'Prefer not to say'];
  final List<String> contactMethods = ['Email', 'Phone', 'Telegram', 'WhatsApp'];

  Future<void> submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final data = {
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'phone': phone,
      'city': city,
      'isVictim': isVictim,
      'contact': wantsContact,
      'preferredContactMethod': preferredContact,
      'story': story,
      'createdAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('users').doc(uid).set(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile submitted successfully')),
    );

    // 🔜 Можешь отправить на главную или другую страницу
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell us about yourself'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Full Name'),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        onSaved: (val) => fullName = val!.trim(),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || int.tryParse(val) == null ? 'Enter a valid age' : null,
                        onSaved: (val) => age = int.tryParse(val!),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField(
                        decoration: const InputDecoration(labelText: 'Gender'),
                        value: gender,
                        items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                        onChanged: (val) => setState(() => gender = val!),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Phone (optional)'),
                        keyboardType: TextInputType.phone,
                        onSaved: (val) => phone = val!.trim(),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'City / Region'),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                        onSaved: (val) => city = val!.trim(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Which of the following applies to you?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RadioListTile(
                        title: const Text('I’m seeking support'),
                        subtitle: const Text('I have experienced violence'),
                        value: true,
                        groupValue: isVictim,
                        onChanged: (val) => setState(() => isVictim = val!),
                      ),
                      RadioListTile(
                        title: const Text('I’m here to support someone'),
                        subtitle: const Text('I want to help someone affected'),
                        value: false,
                        groupValue: isVictim,
                        onChanged: (val) => setState(() => isVictim = val!),
                      ),
                      const SizedBox(height: 20),
                      ExpansionTile(
                        title: const Text('Would you like to share your story?'),
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Your story (optional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 5,
                            onSaved: (val) => story = val!.trim(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        title: const Text('Would you like to be contacted by a lawyer or support group?'),
                        value: wantsContact,
                        onChanged: (val) => setState(() => wantsContact = val),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField(
                        decoration: const InputDecoration(labelText: 'Preferred contact method'),
                        value: preferredContact,
                        items: contactMethods
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) => setState(() => preferredContact = val!),
                      ),
                      const Spacer(),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: submitProfile,
                        child: const Text('Submit Profile'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
