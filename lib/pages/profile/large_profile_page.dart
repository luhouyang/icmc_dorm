import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icmc_dorm/entities/user_entity.dart';
import 'package:icmc_dorm/services/firestore_service/firestore_service.dart';
import 'package:icmc_dorm/states/app_state.dart';
import 'package:icmc_dorm/states/user_state.dart';
import 'package:icmc_dorm/widgets/h1_text.dart';
import 'package:icmc_dorm/widgets/loading_widget.dart';
import 'package:icmc_dorm/widgets/snack_bar_text.dart';
import 'package:icmc_dorm/widgets/text_input.dart';
import 'package:provider/provider.dart';

class LargeProfilePage extends StatefulWidget {
  const LargeProfilePage({super.key});

  @override
  State<LargeProfilePage> createState() => _LargeProfilePageState();
}

class _LargeProfilePageState extends State<LargeProfilePage> {
  TextInputs textInputs = TextInputs();
  SnackBarText snackBarText = SnackBarText();

  final _profileForm = GlobalKey<FormState>();

  List<String> genderList = ["男生", "女生"];
  String _selectedGender = "男生";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    UserState userState = Provider.of<UserState>(context, listen: false);

    TextEditingController nameController = TextEditingController(text: userState.userEntity.name);
    TextEditingController contactController = TextEditingController(
      text: userState.userEntity.contact,
    );
    _selectedGender = userState.userEntity.gender;

    return Scaffold(
      body: SingleChildScrollView(
        child: Consumer2<AppState, UserState>(
          builder: (context, appState, userState, child) {
            return Form(
              key: _profileForm,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    // Name
                    const H1Text(text: "Profile"),
                    SizedBox(height: 24),
                    textInputs.editingTextWidget(
                      controller: nameController,
                      enabled: true,
                      expands: false,
                      validator: textInputs.textVerify,
                    ),
                    const SizedBox(height: 8),
                    // Gender & Contact
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: screenWidth / 3,
                          child: DropdownButtonFormField2<String>(
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                              ),
                              contentPadding: const EdgeInsets.all(8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            hint: const Text('Select Type'),
                            value: _selectedGender,
                            items:
                                genderList
                                    .map(
                                      (item) =>
                                          DropdownMenuItem<String>(value: item, child: Text(item)),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              _selectedGender = value.toString();
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a type';
                              }
                              return null;
                            },
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: Theme.of(context).inputDecorationTheme.fillColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: textInputs.editingTextWidget(
                            controller: contactController,
                            enabled: true,
                            expands: false,
                            validator: textInputs.textVerify,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_profileForm.currentState!.validate()) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return LoadingWidget().circularLoadingWidget(context);
                              },
                            );

                            final newUserEntity = UserEntity(
                              id: userState.userEntity.id,
                              name: nameController.text,
                              gender: _selectedGender,
                              contact: contactController.text,
                            );

                            await FirestoreService()
                                .updateUser(context, newUserEntity, userState.userEntity.id)
                                .then(
                                  (value) => userState.setUserEntity(newUserEntity: newUserEntity),
                                );

                            if (context.mounted) {
                              Navigator.of(context).pop(); // Dismiss loading dialog
                              snackBarText.showBanner(msg: "Updated profile", context: context);
                            }
                          }
                        },
                        style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(20))),
                        child: Text("UPDATE", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 64),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut().then(
                            (value) => userState.clearUserEntity(),
                          );
                        },
                        style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.all(20))),
                        child: Text("LOGOUT", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
