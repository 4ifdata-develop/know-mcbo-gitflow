import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:know_my_city/domain/user/interface_user_facade.dart';
import 'package:know_my_city/domain/user/user_failures.dart';
import 'package:know_my_city/domain/value_objects/email_address.dart';
import 'package:know_my_city/domain/value_objects/password.dart';
//import 'package:know_my_city/domain/value_objects/phone_number.dart';

part 'sing_up_event.dart';
part 'sing_up_state.dart';
part 'sing_up_bloc.freezed.dart';

@injectable
class SingUpBloc extends Bloc<SingUpEvent, SingUpState> {
  final InterfaceUserFacade _interfaceUserFacade;
  SingUpBloc(
    this._interfaceUserFacade,
  ) : super(
          SingUpState.initial(),
        ) {
    on<SingUpEvent>((event, emit) async {
      await event.map(
          started: (e) async {
            // Logica para validar.
          },
          emailChanged: (e) async {
            emit(state.copyWith(
              emailAddress: EmailAddress(e.email),
              userFailureOrUserSuccess: none(),
            ));
          },
          passwordChanged: (e) async {
            emit(state.copyWith(
              password: Password(e.password),
              userFailureOrUserSuccess: none(),
            ));
          },
          signUpMail: (e) async {
            Either<UserFailure, Unit>? failureOrSuccess;
            final isEmailValid = state.emailAddress.isValid();
            final isPasswordValid = state.password.isValid();
            if (isEmailValid && isPasswordValid) {
              emit(state.copyWith(
                isSubmitting: true,
                userFailureOrUserSuccess: none(),
              ));
              failureOrSuccess =
                  await _interfaceUserFacade.registerWithEmailAndPassword(
                emailAddress: state.emailAddress,
                password: state.password,
              );
              failureOrSuccess.fold(
                  (failure) => emit(state.copyWith(
                        isSubmitting: false,
                        //showErrorMessages: true,
                        userFailureOrUserSuccess: some(left(failure)),
                      )),
                  (_) => emit(state.copyWith(
                        isSubmitting: false,
                        userFailureOrUserSuccess: none(),
                      )));
            }
          },
          mailVerification: (e) async {});
    });
  }
}
