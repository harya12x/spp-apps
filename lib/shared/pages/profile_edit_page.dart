import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spp_app/blocs/auth/auth_bloc.dart';
import 'package:spp_app/model/user_edit_form_model.dart';
import 'package:spp_app/shared/helpers.dart';
import 'package:spp_app/shared/theme.dart';
import 'package:spp_app/shared/widgets/buttons.dart';
import 'package:spp_app/shared/widgets/forms.dart';

class ProfileEditPage extends StatefulWidget {
  // final UserModel user;

  const ProfileEditPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  bool isSnackbarShown = false;
  bool isPasswordVisible = false;
  final nisController = TextEditingController(text: '');
  final namasiswaController = TextEditingController(text: '');
  final passwordController = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      nisController.text = authState.user.nis!;
      namasiswaController.text = authState.user.nama_siswa!;
      passwordController.text = authState.user.password!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailed) {
            if (state.e.toString().contains('Connection timed out')) {
              if (state.e.toString().contains(
                  'New password must be different from old password')) {
                if (!isSnackbarShown) {
                  showCustomSnackBar(context,
                      'New password must be different from old password');
                  isSnackbarShown = true;
                }
              } else {
                if (!isSnackbarShown) {
                  showCustomSnackBar(context,
                      'Koneksi timeout. Mohon periksa koneksi internet Anda.');
                  isSnackbarShown = true;
                }
              }
            } else {
              if (!isSnackbarShown) {
                showCustomSnackBar(context, state.e.toString());
                isSnackbarShown = true;
              }
            }
          } else if (state is AuthSuccess) {}
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            children: [
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: whiteColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFormNis(
                      title: 'Nomor Induk Siswa',
                      readOnly: true,
                      controller: nisController,
                      decoration: InputDecoration(),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomFormPassword(
                      title: 'Password',
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CustomFilledButton(
                      title: 'Update Now',
                      onPressed: () async {
                        if (isSnackbarShown) {
                          return;
                        }

                        var connectivityResult =
                            await Connectivity().checkConnectivity();

                        if (connectivityResult == ConnectivityResult.none) {
                          setState(() {
                            isSnackbarShown = true;
                          });
                          showCustomSnackbar(
                              context, "Tidak Ada Koneksi Internet");
                        } else if (passwordController.text.contains("<") ||
                            passwordController.text.contains(">") ||
                            passwordController.text.contains("script")) {
                          setState(() {
                            isSnackbarShown = false;
                          });
                          showCustomSnackbar(context, "Input Tidak Valid !");
                        } else {
                          setState(() {
                            isSnackbarShown = false;
                          });
                          context.read<AuthBloc>().add(
                                AuthUpdateUser(
                                  UserEditFormModel(
                                    nis: nisController.text,
                                    nama_siswa: namasiswaController.text,
                                    password: passwordController.text,
                                  ),
                                ),
                              );
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
